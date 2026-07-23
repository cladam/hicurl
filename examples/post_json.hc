import "../src/cli_spec"
import "../src/item_parser"
import "../src/request"
import "../src/http_exec"
import "../src/filter"

fun main() {
  let args = ["post", "https://httpbin.org/post", "name=Alicia", "age:=15", ".json.name"]
  println("--- Parsing Input Positionals ---")
  println("Input: {show(args)}")
  
  let req = parse_items(args)
  println("Parsed URL: {req.url}")
  println("Parsed Method: {req.method}")
  println("Parsed JSON Fields count: {show(length(req.json_fields))}")
  println("Parsed Filter Path: {show(req.filter_path)}")

  println("\n--- Executing HTTP POST Request ---")
  let resp = execute_request(req)
  println("Status Code: {show(resp.status)}")

  println("\n--- Filtering JSON Response ---")
  match req.filter_path {
    Some(path) => {
      let filtered = filter_response(resp.status, resp.body, resp.headers, path)
      println("Filtered Output: {filtered}")
    },
    None => {
      println("Response Body: {resp.body}")
    }
  }
}
