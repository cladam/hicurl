import "../src/request"
import "../src/item_parser"

test "parse implicit GET and URL" {
  let args = ["/users"]
  let req = parse_items(args)
  assert(req.method == "get")
  assert(req.url == "/users")
  assert(length(req.headers) == 0)
  assert(length(req.queries) == 0)
  assert(length(req.json_fields) == 0)
  assert(is_none(req.filter_path))
}

test "parse explicit POST and URL" {
  let args = ["post", "/users"]
  let req = parse_items(args)
  assert(req.method == "post")
  assert(req.url == "/users")
}

test "parse headers with colon" {
  let args = ["/users", "Accept:application/json", "X-Client-ID:12345"]
  let req = parse_items(args)
  assert(length(req.headers) == 2)
  
  // Let's check headers. Since indexing with [] can be partial/unsafe, we can match on list
  let h0 = match req.headers {
    [h, .._] => h,
    _ => HttpHeader { name: "", content: "" }
  }
  assert(h0.name == "Accept")
  assert(h0.content == "application/json")
}

test "parse json string fields" {
  let args = ["/users", "name=Alice", "role=admin"]
  let req = parse_items(args)
  assert(length(req.json_fields) == 2)
  
  let f0 = match req.json_fields {
    [f, .._] => f,
    _ => JsonField { name: "", content: "", is_raw: false }
  }
  assert(f0.name == "name")
  assert(f0.content == "Alice")
  assert(f0.is_raw == false)
}

test "parse json raw fields" {
  let args = ["/users", "age:=28", "active:=true"]
  let req = parse_items(args)
  assert(length(req.json_fields) == 2)
  
  let f0 = match req.json_fields {
    [f, .._] => f,
    _ => JsonField { name: "", content: "", is_raw: false }
  }
  assert(f0.name == "age")
  assert(f0.content == "28")
  assert(f0.is_raw == true)
}

test "parse queries" {
  let args = ["/search", "query==hica lang", "limit==10"]
  let req = parse_items(args)
  assert(length(req.queries) == 2)
  
  let q0 = match req.queries {
    [q, .._] => q,
    _ => QueryParam { name: "", content: "" }
  }
  assert(q0.name == "query")
  assert(q0.content == "hica lang")
}

test "parse filter path" {
  let args = ["/users", ".path.to.field"]
  let req = parse_items(args)
  assert(req.filter_path == Some(".path.to.field"))
}

test "parse filter status" {
  let args = ["/health", ":status"]
  let req = parse_items(args)
  assert(req.filter_path == Some(":status"))
}

test "parse shorthand localhost URL with port and path" {
  let args = [":8000/v1/health"]
  let req = parse_items(args)
  assert(req.url == "http://localhost:8000/v1/health")
}

test "parse shorthand localhost URL with port only" {
  let args = [":5000"]
  let req = parse_items(args)
  assert(req.url == "http://localhost:5000")
}

test "parse shorthand localhost URL with method" {
  let args = ["post", ":3000/users"]
  let req = parse_items(args)
  assert(req.method == "post")
  assert(req.url == "http://localhost:3000/users")
}

test "parse colon prefix that is not a port" {
  let args = [":invalid"]
  let req = parse_items(args)
  assert(req.url == ":invalid")
}
