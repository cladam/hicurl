import "../src/request"
import "../src/auth"

test "inject bearer auth" {
  let headers = []
  let res = inject_auth(headers, Some("bearer:my-token-123"))
  assert(length(res) == 1)
  
  let h0 = match res {
    [h] => h,
    _ => HttpHeader { name: "", content: "" }
  }
  assert(h0.name == "Authorization")
  assert(h0.content == "Bearer my-token-123")
}

test "inject basic auth" {
  let headers = []
  // basic:user:pass -> b64 of user:pass is dXNlcjpwYXNz
  let res = inject_auth(headers, Some("basic:user:pass"))
  assert(length(res) == 1)
  
  let h0 = match res {
    [h] => h,
    _ => HttpHeader { name: "", content: "" }
  }
  assert(h0.name == "Authorization")
  assert(h0.content == "Basic dXNlcjpwYXNz")
}
