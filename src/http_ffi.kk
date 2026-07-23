module http_ffi

import http

pub fun http_request_full(method: string, url: string, body: string, content_type: string, headers: string) : io http_response
  http_request(method, url, body, content_type, headers)
