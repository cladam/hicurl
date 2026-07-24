module http_ffi

import http

extern import
  c file "http_ffi_inline.c"

extern hicurl_request_raw(
  method        : string,
  url           : string,
  body          : string,
  content_type  : string,
  extra_headers : string,
  timeout       : int
) : io (int, string, string)
  c "kk_hicurl_request"

pub fun http_request_full(method: string, url: string, body: string, content_type: string, headers: string) : io http_response
  val (status, body_str, hdrs) = hicurl_request_raw(method, url, body, content_type, headers, 0)
  Http_response(status, body_str, hdrs)
