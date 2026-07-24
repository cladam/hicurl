import "http_client"
import "json"

pub fun format_time_us(us_str: string) : string {
  match parse_int(us_str) {
    Some(us) => {
      if us < 1000 {
        show(us) + "us"
      } else if us < 1000000 {
        let ms = us / 1000
        show(ms) + "ms"
      } else {
        let secs = us / 1000000
        let rem = (us % 1000000) / 10000
        let rem_str = if rem < 10 { "0" + show(rem) } else { show(rem) }
        show(secs) + "." + rem_str + "s"
      }
    },
    None => "(timing not available)"
  }
}

pub fun extract_cookie(headers: string, target_name: string) : string {
  let sc_headers = filter(parse_headers(headers), (h) => match h { Header { name: n, value: _ } => to_lower(n) == "set-cookie" })
  find_cookie_in_headers(sc_headers, target_name)
}

pub fun find_cookie_in_headers(hdrs: list<Header>, target_name: string) : string => match hdrs {
  [] => "(cookie not found)",
  [h, ..rest] => {
    match h {
      Header { name: _, value: val } => {
        let parts = split(val, ";")
        match parts {
          [] => find_cookie_in_headers(rest, target_name),
          [first, .._] => {
            let kv_parts = split(first, "=")
            match kv_parts {
              [k, ..v_rest] => {
                if trim(k) == target_name {
                  trim(join(v_rest, "="))
                } else {
                  find_cookie_in_headers(rest, target_name)
                }
              },
              _ => find_cookie_in_headers(rest, target_name)
            }
          }
        }
      }
    }
  }
}

pub fun filter_response(status: int, body: string, headers: string, filter_path: string) : string {
  if filter_path == ":status" {
    show(status)
  } else if filter_path == ":headers" {
    let lines_list = filter(split(headers, "\n"), (line) => !starts_with(line, "__hicurl_"))
    join(lines_list, "\n")
  } else if starts_with(filter_path, ":header.") {
    let header_name = filter_path[8:]
    unwrap_maybe_or(find_header(headers, header_name), "(header not found)")
  } else if filter_path == ":time" {
    unwrap_maybe_or(map_maybe(find_header(headers, "__hicurl_total_us"), format_time_us), "(timing not available)")
  } else if filter_path == ":time.dns" {
    unwrap_maybe_or(map_maybe(find_header(headers, "__hicurl_dns_us"), format_time_us), "(timing not available)")
  } else if filter_path == ":time.connect" {
    unwrap_maybe_or(map_maybe(find_header(headers, "__hicurl_connect_us"), format_time_us), "(timing not available)")
  } else if filter_path == ":time.ttfb" {
    unwrap_maybe_or(map_maybe(find_header(headers, "__hicurl_ttfb_us"), format_time_us), "(timing not available)")
  } else if filter_path == ":cookie" || filter_path == ":cookies" {
    let sc_headers = filter(parse_headers(headers), (h) => match h { Header { name: n, value: _ } => to_lower(n) == "set-cookie" })
    let cookie_values = map(sc_headers, (h) => match h { Header { name: _, value: val } => val })
    join(cookie_values, "\n")
  } else if starts_with(filter_path, ":cookie.") {
    let cookie_name = filter_path[8:]
    extract_cookie(headers, cookie_name)
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
