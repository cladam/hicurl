import "std/list"
import "std/string"

pub struct Header {
  name: string,
  content: string
}

pub struct QueryParam {
  name: string,
  content: string
}

pub struct JsonField {
  name: string,
  content: string,
  is_raw: bool
}

pub struct RequestSpec {
  url: string,
  method: string,
  headers: list<Header>,
  queries: list<QueryParam>,
  json_fields: list<JsonField>,
  filter_path: maybe<string>
}

pub fun empty_request() =>
  RequestSpec {
    url: "",
    method: "get",
    headers: [],
    queries: [],
    json_fields: [],
    filter_path: None
  }
