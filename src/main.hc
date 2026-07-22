// hicurl - a modern HTTP CLI

import "std/cli"
import "parser"
import "item_parser"
import "request"
import "http_exec"

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
      
      let res_body = execute_request(req)
      println("Response:")
      println(res_body)
    }
  }
}
