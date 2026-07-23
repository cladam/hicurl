// hicurl - a modern HTTP CLI

import "std/cli"
import "cli_spec"
import "item_parser"
import "request"
import "http_exec"
import "filter"
import "json"
import "auth"
import "env_loader"
import "export"

fun main() {
  let spec = make_spec()
  match cli_parse(spec) {
    Help          => println(cli_help(spec)),
    Version       => println(cli_version_str(spec)),
    CliError(msg) => eprintln("error: {msg}"),
    Parsed(r)     => {
      println("CLI Parsed successfully!")
      let env = get_opt(r, "env")
      let auth = get_opt(r, "auth")
      let export_val = get_opt(r, "export")
      let pos = get_positionals(r)
      
      println("env: {show(env)}")
      println("auth: {show(auth)}")
      println("export: {show(export_val)}")
      println("positionals: {show(pos)}")
      
      let req = parse_items(pos)
      let resolved_url = resolve_url(req.url, env)
      let resolved_headers = inject_auth(req.headers, auth)
      let resolved_req = RequestSpec {
        url: resolved_url,
        method: req.method,
        headers: resolved_headers,
        queries: req.queries,
        json_fields: req.json_fields,
        filter_path: req.filter_path
      }
      
      println("Parsed URL: {resolved_req.url}")
      println("Parsed Method: {resolved_req.method}")
      
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
          match req.filter_path {
            Some(path) => {
              let filtered = filter_response(resp.status, resp.body, resp.headers, path)
              println(filtered)
            },
            None => {
              println("Response Body:")
              println(resp.body)
            }
          }
        }
      }
    }
  }
}
