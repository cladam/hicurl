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

test "parse_url_host_path helper" {
  let r1 = parse_url_host_path("http://localhost:3000/users")
  assert(r1.0 == "localhost:3000")
  assert(r1.1 == "/users")

  let r2 = parse_url_host_path("/api/v1/posts")
  assert(r2.0 == "localhost")
  assert(r2.1 == "/api/v1/posts")

  let r3 = parse_url_host_path("https://example.com")
  assert(r3.0 == "example.com")
  assert(r3.1 == "/")
}

test "export POST http dry-run" {
  let req = RequestSpec {
    url: "https://example.com/api/login",
    method: "post",
    headers: [HttpHeader { name: "X-Request-ID", content: "12345" }],
    queries: [QueryParam { name: "v", content: "2" }],
    json_fields: [JsonField { name: "username", content: "cladam", is_raw: false }],
    filter_path: None,
    is_form: false
  }
  
  let res = export_http(req)
  assert(contains(res, "POST /api/login?v=2 HTTP/1.1"))
  assert(contains(res, "Host: example.com"))
  assert(contains(res, "Content-Type: application/json"))
  assert(contains(res, "Content-Length: 22"))
  assert(contains(res, "X-Request-ID: 12345"))
  assert(contains(res, "\{\"username\": \"cladam\"\}"))
}
