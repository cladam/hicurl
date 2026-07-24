import "request"
import "std/string"

pub fun parse_url_host_path(url: string) : (string, string) {
  let clean_url = if starts_with(url, "http://") {
    url[7:]
  } else if starts_with(url, "https://") {
    url[8:]
  } else {
    url
  }
  
  match index_of(clean_url, "/") {
    None => {
      let host = if clean_url == "" { "localhost" } else { clean_url }
      (host, "/")
    },
    Some(idx) => {
      let host_part = clean_url[:idx]
      let host = if host_part == "" { "localhost" } else { host_part }
      let path = clean_url[idx:]
      (host, path)
    }
  }
}

pub fun export_http(req: RequestSpec) : string {
  let (host, path) = parse_url_host_path(req.url)
  
  // Build query string
  let query_string = join(map(req.queries, (q) => q.name + "=" + q.content), "&")
  let full_path = if query_string == "" {
    path
  } else {
    path + "?" + query_string
  }
  
  let method_upper = to_upper(req.method)
  let request_line = method_upper + " " + full_path + " HTTP/1.1"
  
  // Build body
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
  
  // Build headers
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
  
  let host_header = "Host: " + host
  let ua_header = "User-Agent: hica-http/1.0"
  let accept_header = "Accept: */*"
  
  let std_headers = [host_header, ua_header, accept_header]
  let std_headers_with_ct = if content_type_header == "" {
    std_headers
  } else {
    std_headers + [content_type_header]
  }
  
  let std_headers_with_cl = if body_str == "" {
    std_headers_with_ct
  } else {
    std_headers_with_ct + ["Content-Length: " + show(str_length(body_str))]
  }
  
  let custom_headers = map(req.headers, (h) => h.name + ": " + h.content)
  let all_headers = std_headers_with_cl + custom_headers
  
  let headers_str = join(all_headers, "\n")
  
  if body_str == "" {
    request_line + "\n" + headers_str + "\n\n"
  } else {
    request_line + "\n" + headers_str + "\n\n" + body_str
  }
}

pub fun export_curl(req: RequestSpec) : string {
  let parts = ["curl"]
  
  // Add method if not GET (or if explicit)
  let method_upper = to_upper(req.method)
  let parts_with_method = if method_upper != "GET" {
    parts + ["-X " + method_upper]
  } else {
    parts
  }

  // Add headers
  let parts_with_headers = fold(req.headers, parts_with_method, (acc, h) =>
    acc + ["-H \"" + h.name + ": " + h.content + "\""]
  )

  // Add Content-Type header if JSON fields are present
  let parts_with_ct = if length(req.json_fields) > 0 {
    if req.is_form {
      parts_with_headers + ["-H \"Content-Type: application/x-www-form-urlencoded\""]
    } else {
      parts_with_headers + ["-H \"Content-Type: application/json\""]
    }
  } else {
    parts_with_headers
  }

  // Add query parameters using modern --url-query format
  let parts_with_queries = fold(req.queries, parts_with_ct, (acc, q) =>
    acc + ["--url-query \"" + q.name + "=" + q.content + "\""]
  )

  // Add JSON/form body if present
  let parts_with_body = if length(req.json_fields) > 0 {
    if req.is_form {
      let fields = map(req.json_fields, (f) => f.name + "=" + f.content)
      let body_str = join(fields, "&")
      parts_with_queries + ["-d \"" + body_str + "\""]
    } else {
      let fields = map(req.json_fields, (f) => {
        if f.is_raw {
          "\"" + f.name + "\": " + f.content
        } else {
          "\"" + f.name + "\": \"" + f.content + "\""
        }
      })
      let body_str = "\{" + join(fields, ", ") + "\}"
      parts_with_queries + ["-d '" + body_str + "'"]
    }
  } else {
    parts_with_queries
  }

  // Add the base URL at the end
  let final_parts = parts_with_body + ["\"" + req.url + "\""]
  
  join(final_parts, " ")
}
