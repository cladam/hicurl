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

extern hicurl_stdout_isatty_raw() : io bool
  c "kk_hicurl_stdout_isatty"

extern hicurl_version_raw() : io string
  c "kk_hicurl_version"

pub fun stdout_isatty() : io bool
  hicurl_stdout_isatty_raw()

pub fun hicurl_version() : io string
  hicurl_version_raw()

pub fun http_request_full(method: string, url: string, body: string, content_type: string, headers: string) : io http_response
  val (status, body_str, hdrs) = hicurl_request_raw(method, url, body, content_type, headers, 0)
  Http_response(status, body_str, hdrs)
