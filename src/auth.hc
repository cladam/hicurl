import "base64"
import "request"

pub fun inject_auth(headers: list<HttpHeader>, auth_opt: maybe<string>) : list<HttpHeader> =>
  match auth_opt {
    None => headers,
    Some(opt) => {
      match index_of(opt, ":") {
        Some(idx) => {
          let auth_type = to_lower(opt[0:idx])
          let credentials = opt[idx+1:]
          
          if auth_type == "bearer" {
            headers + [HttpHeader { name: "Authorization", content: "Bearer " + credentials }]
          } else if auth_type == "basic" {
            let encoded = b64_encode(credentials)
            headers + [HttpHeader { name: "Authorization", content: "Basic " + encoded }]
          } else {
            headers
          }
        },
        None => headers
      }
    }
  }
