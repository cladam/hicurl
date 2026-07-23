import "http_client"
import "json"

pub fun filter_response(status: int, body: string, headers: string, filter_path: string) : string {
  if filter_path == ":status" {
    show(status)
  } else if filter_path == ":headers" {
    headers
  } else if starts_with(filter_path, ":header.") {
    let header_name = filter_path[8:]
    unwrap_maybe_or(find_header(headers, header_name), "(header not found)")
  } else if starts_with(filter_path, ".") {
    if status < 200 || status >= 300 {
      "(HTTP Error " + show(status) + ")"
    } else {
      // Navigate JSON dot path
      let parts = filter(split(filter_path, "."), (s) => s != "")
      match parse_json(body) {
        Ok(j) => {
          let matched = navigate_json(Some(j), parts)
          match matched {
            Some(res) => format_json_result(res),
            None => "(field not found)"
          }
        },
        Err(err) => "(invalid JSON response: " + err + ")"
      }
    }
  } else {
    "(unknown filter: " + filter_path + ")"
  }
}

pub fun navigate_json(j: maybe<Json>, path_parts: list<string>) : maybe<Json> => match path_parts {
  [] => j,
  [p, ..rest] => {
    let next_j = if starts_with(p, "[") && ends_with(p, "]") {
      let idx_str = p[1:length(p)-1]
      match parse_int(idx_str) {
        Some(idx) => nth(j, idx),
        None => None
      }
    } else {
      at(j, p)
    }
    navigate_json(next_j, rest)
  }
}

pub fun format_json_result(j: Json) : string => match j {
  JString(s) => s,
  _ => json_emit(j)
}
