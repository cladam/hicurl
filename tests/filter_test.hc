import "../src/filter"
import "json"

test "filter json dot-path" {
  let body = "\{\"args\": \{\"query\": \"hica\"\}\}"
  let res = filter_response(200, body, "", ".args.query")
  assert(res == "hica")
}

test "filter status" {
  let res = filter_response(404, "", "", ":status")
  assert(res == "404")
}

test "filter headers" {
  let res = filter_response(200, "", "Content-Type: text/plain\n", ":headers")
  assert(res == "Content-Type: text/plain\n")
}

test "filter header name" {
  let res = filter_response(200, "", "Content-Type: text/plain\n", ":header.Content-Type")
  assert(res == "text/plain")
}

test "filter timing ms" {
  let res = filter_response(200, "", "__hicurl_total_us: 142000\n", ":time")
  assert(res == "142ms")
}

test "filter timing seconds" {
  let res = filter_response(200, "", "__hicurl_total_us: 1840000\n", ":time")
  assert(res == "1.84s")
}

test "filter timing leading zero seconds" {
  let res = filter_response(200, "", "__hicurl_total_us: 1040000\n", ":time")
  assert(res == "1.04s")
}

test "filter timing dns" {
  let res = filter_response(200, "", "__hicurl_dns_us: 12000\n", ":time.dns")
  assert(res == "12ms")
}

test "filter all cookies" {
  let hdrs = "Set-Cookie: session_id=abc123xyz; Path=/; Secure; HttpOnly\nSet-Cookie: csrf_token=987654321; Path=/\n"
  let res = filter_response(200, "", hdrs, ":cookie")
  assert(res == "session_id=abc123xyz; Path=/; Secure; HttpOnly\ncsrf_token=987654321; Path=/")
}

test "filter single cookie" {
  let hdrs = "Set-Cookie: session_id=abc123xyz; Path=/; Secure; HttpOnly\nSet-Cookie: csrf_token=987654321; Path=/\n"
  let res = filter_response(200, "", hdrs, ":cookie.session_id")
  assert(res == "abc123xyz")
}

test "filter single cookie with equal signs" {
  let hdrs = "Set-Cookie: session_id=abc=def; Path=/\n"
  let res = filter_response(200, "", hdrs, ":cookie.session_id")
  assert(res == "abc=def")
}

test "filter missing cookie" {
  let hdrs = "Set-Cookie: session_id=abc123xyz; Path=/\n"
  let res = filter_response(200, "", hdrs, ":cookie.csrf_token")
  assert(res == "(cookie not found)")
}

test "filter headers stripping internal telemetry" {
  let hdrs = "Content-Type: text/plain\n__hicurl_total_us: 142000\n__hicurl_dns_us: 12000\n"
  let res = filter_response(200, "", hdrs, ":headers")
  assert(res == "Content-Type: text/plain\n")
}

test "filter json array bracket index" {
  let body = "\{\"items\": [\{\"language\": \"Rust\"\}, \{\"language\": \"Go\"\}]\}"
  let res = filter_response(200, body, "", ".items.[0].language")
  assert(res == "Rust")
}

test "filter json array dot-separated integer index" {
  let body = "\{\"items\": [\{\"language\": \"Rust\"\}, \{\"language\": \"Go\"\}]\}"
  let res = filter_response(200, body, "", ".items.1.language")
  assert(res == "Go")
}
