# hicurl

A modern HTTP CLI built in [hica](https://www.hica.dev) with a rich feature set and intuitive syntax sugar.

## Install

Using regular `curl`:
```sh
curl -fsSL https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
```

Using `hicurl`:
```sh
hicurl https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
```

#### ### Why this works:

1. **Implicit GET**: Passing a URL without an explicit method defaults to a `GET` request.
2. **Auto-redirects**: The underlying `libcurl` implementation in **hicurl** automatically follows location redirects (the equivalent of `-L` in curl).
3. **Piping & TTY detection**: When piped to `sh`, **hicurl** detects that stdout is not a TTY (terminal), so it prints the raw shell script directly to the pipeline without any ANSI colors or JSON formatting, making it perfectly clean for the shell to execute.

This downloads the pre-built binary for your platform (`macos-arm64`, `linux-arm64` and `linux-x86_64`) and installs it to `~/.local/bin`. Override the install directory with `HICURL_INSTALL_DIR`:

```sh
HICURL_INSTALL_DIR=/usr/local/bin curl -fsSL https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
# Or with hicurl
HICURL_INSTALL_DIR=/usr/local/bin hicurl https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
```

**Note:** _No Windows installer yet_

## Features

- **Base CLI Parser**: Configured via `std/cli` with options for `--auth` (`-A`), `--env` (`-e`), and `--export` (`-E`).
- **Flexible Syntax Sugar**: Positionals are dynamically parsed into headers (`:`), query parameters (`==`), JSON string fields (`=`), JSON raw fields (`:=`), and response filters (`.` / `:status` / `:headers`).
- **Automatic Method & URL Routing**: Correctly infers implicit `GET` or explicit methods (`post`, `put`, `delete`, etc.) and handles positional routing.
- **HTTP Execution**: Fully integrated HTTP client engine utilising `libcurl` via Koka FFI to execute GET, POST, and other HTTP requests with the parsed headers, query parameters, and custom JSON bodies.
- **Response Filtering**: Rich response filters supporting Status Codes (`:status`), Raw Headers (`:headers`), case-insensitive specific header values (`:header.Header-Name`), and nested JSON dot-path navigation including array indexing (e.g. `.path.to.field` or `.[0].name`).
- **Auth Sugar Injection**: Seamless authentication configuration via `-A` / `--auth` supporting Bearer token headers (`-A bearer:TOKEN`) and auto-Base64 encoded Basic auth (`-A basic:user:pass`).
- **Environment Base URL Resolution**: Dynamically reads environment mapping from `.hicurl.env` (via `-e` / `--env`), automatically prepending the selected base URL if the requested path is relative. Supports fallbacks to locate `.hicurl.env` from either the current directory or parent directories.
- **Code Export Mode (curl)**: Export parsed queries, headers, and JSON bodies to a fully-escaped, standard `curl` command using `-E curl` / `--export curl`. Leverages the modern `--url-query` parameter for robust query parameter formatting, bypassing HTTP execution when active.
- **Response Timing Diagnostics**: Seamless measurement of request execution times right from `libcurl`. Supports `:time` (formatted as ms or seconds, e.g. `142ms`, `1.84s`), plus granular breakdowns: `:time.dns` (DNS lookup), `:time.connect` (TCP connection), and `:time.ttfb` (Time To First Byte).
- **Cookie Inspection**: Clean extraction of authentication & session state from response headers. Supports `:cookie` / `:cookies` (to list all received cookies) and targeted extraction via `:cookie.CookieName` (e.g. `:cookie.session_id`) returning raw, unquoted values for scripting convenience.
- **TTY-Aware Output Formatting**: Automatically detects terminal capabilities (`stdout` TTY detection). If outputting to a TTY, JSON responses (including filtered ones) are pretty-printed and colourised with ANSI terminal colors (cyan keys, green strings, yellow numbers, magenta booleans, and dim nulls) for optimal readability. When piped, redirected, or filtered in non-TTY environments, it retains uncoloured raw output to keep shell scripts clean.

## Syntax Examples

```sh
# Implicit GET
hicurl /users

# Explicit POST with JSON body and custom Header
hicurl post /users name="Alicia" role="admin" age:=28 X-Client-ID:12345

# GET with query params and response filter
hicurl get /search query=="hica lang" limit==10 .results

# Bearer Token Auth
hicurl /v1/me -A bearer:super-secret-token

# Auto-Base64 Basic Auth
hicurl /v1/me -A basic:my_user:secret

# Environment Base URL Resolution (loads base URL from .hicurl.env)
hicurl /posts/1 -e staging

# Export to curl format
hicurl post /users name="Sara" age:=52 -E curl

# Measure response time and latency breakdowns
hicurl get /heavy-query :time :time.dns :time.ttfb

# Cookie extraction
hicurl post /api/login username=claes password=secret :cookie.session_id
```

## Running Tests

To run the full test suite:

```sh
# Parser test suite
hica test tests/parser_test.hc

# Response filter test suite
hica test tests/filter_test.hc

# Auth injection test suite
hica test tests/auth_test.hc

# Environment loader test suite
hica test tests/env_test.hc

# Code export test suite
hica test tests/export_test.hc
```

## Running Examples

To execute the examples shell script using the compiled binary:

```sh
./examples/run_hicurl_examples.sh
```

## Toolchain Development commands

```sh
hica build   # compile to binary
hica run     # compile and run
hica fmt     # format according to hica style guide
hica check   # type-check without emitting
hica clean   # remove generated files
```
