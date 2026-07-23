import "request"

pub fun export_curl(req: RequestSpec) : string {
  let parts = ["curl"]
  
  // 1. Add method if not GET (or if explicit)
  let method_upper = to_upper(req.method)
  let parts_with_method = if method_upper != "GET" {
    parts + ["-X " + method_upper]
  } else {
    parts
  }

  // 2. Add headers
  let parts_with_headers = fold(req.headers, parts_with_method, (acc, h) =>
    acc + ["-H \"" + h.name + ": " + h.content + "\""]
  )

  // 3. Add Content-Type header if JSON fields are present
  let parts_with_ct = if length(req.json_fields) > 0 {
    parts_with_headers + ["-H \"Content-Type: application/json\""]
  } else {
    parts_with_headers
  }

  // 4. Add query parameters using modern --url-query format
  let parts_with_queries = fold(req.queries, parts_with_ct, (acc, q) =>
    acc + ["--url-query \"" + q.name + "=" + q.content + "\""]
  )

  // 5. Add JSON body if present
  let parts_with_body = if length(req.json_fields) > 0 {
    let fields = map(req.json_fields, (f) => {
      if f.is_raw {
        "\"" + f.name + "\": " + f.content
      } else {
        "\"" + f.name + "\": \"" + f.content + "\""
      }
    })
    let body_str = "\{" + join(fields, ", ") + "\}"
    parts_with_queries + ["-d '" + body_str + "'"]
  } else {
    parts_with_queries
  }

  // 6. Add the base URL at the end
  let final_parts = parts_with_body + ["\"" + req.url + "\""]
  
  join(final_parts, " ")
}
