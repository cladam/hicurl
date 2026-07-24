import "../src/request"
import "../src/export"

test "export simple GET curl" {
  let req = RequestSpec {
    url: "https://httpbin.org/get",
    method: "get",
    headers: [],
    queries: [QueryParam { name: "limit", content: "10" }],
    json_fields: [],
    filter_path: None,
    is_form: false
  }
  
  let res = export_curl(req)
  assert(res == "curl --url-query \"limit=10\" \"https://httpbin.org/get\"")
}

test "export POST curl with JSON body" {
  let req = RequestSpec {
    url: "https://httpbin.org/post",
    method: "post",
    headers: [HttpHeader { name: "X-Client", content: "hicurl" }],
    queries: [],
    json_fields: [JsonField { name: "name", content: "Alice", is_raw: false }],
    filter_path: None,
    is_form: false
  }
  
  let res = export_curl(req)
  // curl -X POST -H "X-Client: hicurl" -H "Content-Type: application/json" -d '{"name": "Alice"}' "https://httpbin.org/post"
  assert(contains(res, "-X POST"))
  assert(contains(res, "-H \"X-Client: hicurl\""))
  assert(contains(res, "-H \"Content-Type: application/json\""))
  assert(contains(res, "-d '\{\"name\": \"Alice\"\}'"))
}

test "export POST curl with form-encoding" {
  let req = RequestSpec {
    url: "https://httpbin.org/post",
    method: "post",
    headers: [],
    queries: [],
    json_fields: [JsonField { name: "name", content: "Alice", is_raw: false }, JsonField { name: "age", content: "30", is_raw: true }],
    filter_path: None,
    is_form: true
  }
  
  let res = export_curl(req)
  assert(contains(res, "-X POST"))
  assert(contains(res, "-H \"Content-Type: application/x-www-form-urlencoded\""))
  assert(contains(res, "-d \"name=Alice&age=30\""))
}
