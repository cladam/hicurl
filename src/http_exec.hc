extern import "http_ffi"
extern import "http"
import "request"

pub fun execute_request(req: RequestSpec) {
  // First, convert queries to list of Param
  let query_string = join(map(req.queries, (q) => q.name + "=" + q.content), "&")
  let full_url = if query_string == "" {
    req.url
  } else {
    req.url + "?" + query_string
  }

  // Next, build headers.
  let content_type = if length(req.json_fields) > 0 {
    if req.is_form {
      "application/x-www-form-urlencoded"
    } else {
      "application/json"
    }
  } else {
    ""
  }

  let content_type_header = if content_type == "" {
    ""
  } else {
    "Content-Type: " + content_type
  }
  
  let custom_headers = map(req.headers, (h) => h.name + ": " + h.content)
  let all_headers = if content_type_header == "" {
    custom_headers
  } else {
    [content_type_header] + custom_headers
  }
  let headers_str = join(all_headers, "\n")

  // Next, build body manually
  let body_str = if length(req.json_fields) > 0 {
    if req.is_form {
      let fields = map(req.json_fields, (f) => f.name + "=" + f.content)
      join(fields, "&")
    } else {
      let fields = map(req.json_fields, (f) => {
        if f.is_raw {
          "\"" + f.name + "\": " + f.content
        } else {
          "\"" + f.name + "\": \"" + f.content + "\""
        }
      })
      "\{" + join(fields, ", ") + "\}"
    }
  } else {
    ""
  }

  // Execute using http_request_full from http_ffi
  let resp = http_request_full(to_upper(req.method), full_url, body_str, content_type, headers_str)
  resp
}
