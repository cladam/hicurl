// hicurl - a modern HTTP CLI

import "std/cli"
import "std/term"
import "cli_spec"
import "item_parser"
import "request"
import "http_exec"
import "filter"
import "json"
import "auth"
import "env_loader"
import "export"
extern import "http_ffi"

fun main() {
  let spec = make_spec()
  match cli_parse(spec) {
    Help          => println(cli_help_extended(spec)),
    Version       => {
      println(cli_version_str(spec))
      println(hicurl_version())
    },
    CliError(msg) => eprintln("error: {msg}"),
    Parsed(r)     => {
      let verbose = has_flag(r, "verbose")
      let is_form = has_flag(r, "form")
      let dry_run = has_flag(r, "dry-run")
      let curl_flag = has_flag(r, "curl")
      let json_out = has_flag(r, "json")
      if verbose {
        println("Verbose mode is ON")
        println("CLI Parsed successfully!")
      }

      let env = get_opt(r, "env")
      let auth = get_opt(r, "auth")
      let export_val = if curl_flag { Some("curl") } else { get_opt(r, "export") }
      let pos = get_positionals(r)
      
      if verbose {
        println("env: {show(env)}")
        println("auth: {show(auth)}")
        println("export: {show(export_val)}")
        println("positionals: {show(pos)}")
      }
      
      let req = parse_items(pos)
      let resolved_url = resolve_url(req.url, env)
      let resolved_headers = inject_auth(req.headers, auth)
      let resolved_req = RequestSpec {
        url: resolved_url,
        method: req.method,
        headers: resolved_headers,
        queries: req.queries,
        json_fields: req.json_fields,
        filter_paths: req.filter_paths,
        is_form: is_form
      }
      
      if verbose {
        println("Parsed URL: {resolved_req.url}")
        println("Parsed Method: {resolved_req.method}")
      }
      
      let is_dry_run = dry_run || match export_val {
        Some("http") => true,
        _ => false
      }

      if is_dry_run {
        let http_req = export_http(resolved_req)
        println(http_req)
      } else {
        match export_val {
          Some("curl") => {
            let curl_cmd = export_curl(resolved_req)
            println(curl_cmd)
          },
          Some(unsupported) => {
            println("(unsupported export: {unsupported})")
          },
          None => {
            let resp = execute_request(resolved_req)
            if json_out {
              let parsed_body = match parse_json(resp.body) {
                Ok(j) => j,
                Err(_) => JString(resp.body)
              }
              
              let out = JObject([
                ("status", JInt(resp.status)),
                ("headers", JString(resp.headers)),
                ("body", parsed_body)
              ])
              if stdout_isatty() {
                println(pretty_colorize_json(out, 0))
              } else {
                println(json_stringify(out))
              }
            } else {
              match req.filter_paths {
                [] => {
                  if verbose {
                    println("Response Body:")
                  }
                  print_response_body(resp.body)
                },
                paths => {
                  let filtered_results = map(paths, (path) => filter_response(resp.status, resp.body, resp.headers, path))
                  if length(paths) == 1 {
                    match head(filtered_results) {
                      Some(res) => { print_response_body(res) },
                      None => {}
                    }
                  } else {
                    println(join(filtered_results, "\n"))
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

pub fun pretty_colorize_json(j: Json, indent: int) : string {
  match j {
    JObject(fields) => {
      if length(fields) == 0 {
        "\{\}"
      } else {
        let pad = make_indent(indent)
        let inner_pad = make_indent(indent + 1)
        let field_strings = map(fields, (f) => {
          let key_str = cyan("\"" + escape_string(f.0) + "\"")
          let val_str = pretty_colorize_json_no_pad(f.1, indent + 1)
          inner_pad + key_str + ": " + val_str
        })
        let inner = join(field_strings, ",\n")
        "\{" + "\n" + inner + "\n" + pad + "\}"
      }
    },
    JArray(items) => {
      if length(items) == 0 {
        "[]"
      } else {
        let pad = make_indent(indent)
        let inner_pad = make_indent(indent + 1)
        let item_strings = map(items, (i) => {
          inner_pad + pretty_colorize_json_no_pad(i, indent + 1)
        })
        let inner = join(item_strings, ",\n")
        "[\n" + inner + "\n" + pad + "]"
      }
    },
    _ => pretty_colorize_json_no_pad(j, indent)
  }
}

pub fun pretty_colorize_json_no_pad(j: Json, indent: int) : string => match j {
  JNull => dim("null"),
  JBool(b) => magenta(if b { "true" } else { "false" }),
  JInt(n) => yellow(show(n)),
  JNumber(n) => yellow(json_number(n)),
  JString(s) => green("\"" + escape_string(s) + "\""),
  JArray(_) => pretty_colorize_json(j, indent),
  JObject(_) => pretty_colorize_json(j, indent)
}

pub fun json_stringify(j: Json) : string => match j {
  JNull => "null",
  JBool(b) => if b { "true" } else { "false" },
  JInt(n) => show(n),
  JNumber(n) => json_number(n),
  JString(s) => "\"" + escape_string(s) + "\"",
  JArray(items) => "[" + join(map(items, json_stringify), ",") + "]",
  JObject(fields) => {
    let field_strings = map(fields, (f) => "\"" + escape_string(f.0) + "\":" + json_stringify(f.1))
    "\{" + join(field_strings, ",") + "\}"
  }
}

pub fun print_response_body(body: string) {
  if stdout_isatty() {
    match parse_json(body) {
      Ok(j) => {
        println(pretty_colorize_json(j, 0))
      },
      Err(_) => {
        println(body)
      }
    }
  } else {
    println(body)
  }
}
