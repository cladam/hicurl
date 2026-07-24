import "std/list"
import "std/string"
import "request"

pub fun parse_items(args: list<string>) : RequestSpec {
  let initial = empty_request()
  match args {
    [] => initial,
    [url, ..rest] => parse_rest(initial, url, rest)
  }
}

pub fun expand_shorthand_url(url: string) : string {
  if starts_with(url, ":") {
    let first_char = url[1:2]
    if first_char == "0" || first_char == "1" || first_char == "2" || first_char == "3" || first_char == "4" || first_char == "5" || first_char == "6" || first_char == "7" || first_char == "8" || first_char == "9" {
      "http://localhost" + url
    } else {
      url
    }
  } else {
    url
  }
}

pub fun parse_rest(req: RequestSpec, first_arg: string, rest: list<string>) : RequestSpec {
  let is_method = match to_lower(first_arg) {
    "get" | "post" | "put" | "patch" | "delete" | "head" => true,
    _ => false
  }

  let (method, raw_url, items) = if is_method {
    match rest {
      [] => (first_arg, "", []),
      [u, ..more] => (first_arg, u, more)
    }
  } else {
    ("get", first_arg, rest)
  }

  let url = expand_shorthand_url(raw_url)

  let base_req = RequestSpec {
    url: url,
    method: to_lower(method),
    headers: req.headers,
    queries: req.queries,
    json_fields: req.json_fields,
    filter_path: req.filter_path,
    is_form: req.is_form
  }
  
  fold(items, base_req, parse_single_item)
}

pub fun parse_single_item(req: RequestSpec, item: string) : RequestSpec =>
  if starts_with(item, ".") || starts_with(item, ":") {
    if item == ":status" || item == ":headers" || item == ":time" || item == ":time.dns" || item == ":time.connect" || item == ":time.ttfb" || item == ":cookie" || item == ":cookies" || starts_with(item, ":cookie.") || starts_with(item, ".") || starts_with(item, ":header.") {
      RequestSpec { url: req.url, method: req.method, headers: req.headers, queries: req.queries, json_fields: req.json_fields, filter_path: Some(item), is_form: req.is_form }
    } else {
      parse_operator(req, item)
    }
  } else {
    parse_operator(req, item)
  }

pub fun parse_operator(req: RequestSpec, item: string) : RequestSpec =>
  match index_of(item, "==") {
    Some(idx) => {
      let name = item[0:idx]
      let val = item[idx+2:]
      RequestSpec { url: req.url, method: req.method, headers: req.headers, queries: req.queries + [QueryParam { name: name, content: val }], json_fields: req.json_fields, filter_path: req.filter_path, is_form: req.is_form }
    },
    None => match index_of(item, ":=") {
      Some(idx) => {
        let name = item[0:idx]
        let val = item[idx+2:]
        RequestSpec { url: req.url, method: req.method, headers: req.headers, queries: req.queries, json_fields: req.json_fields + [JsonField { name: name, content: val, is_raw: true }], filter_path: req.filter_path, is_form: req.is_form }
      },
      None => match index_of(item, "=") {
        Some(idx) => {
          let name = item[0:idx]
          let val = item[idx+1:]
          RequestSpec { url: req.url, method: req.method, headers: req.headers, queries: req.queries, json_fields: req.json_fields + [JsonField { name: name, content: val, is_raw: false }], filter_path: req.filter_path, is_form: req.is_form }
        },
        None => match index_of(item, ":") {
          Some(idx) => {
            let name = item[0:idx]
            let val = item[idx+1:]
            RequestSpec { url: req.url, method: req.method, headers: req.headers + [HttpHeader { name: name, content: val }], queries: req.queries, json_fields: req.json_fields, filter_path: req.filter_path, is_form: req.is_form }
          },
          None => req
        }
      }
    }
  }
