// hicurl - a modern HTTP CLI

import "std/cli"
import "cli_spec"
import "item_parser"
import "request"
import "http_exec"
import "filter"
import "json"

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
      println("Parsed URL: {req.url}")
      println("Parsed Method: {req.method}")
      
      let resp = execute_request(req)
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
