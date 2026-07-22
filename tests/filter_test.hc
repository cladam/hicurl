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
