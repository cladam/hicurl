# hicurl

A modern HTTP CLI built in [hica](https://www.hica.dev). Heavily inspired by the human-friendly ergonomics of **HTTPie** and **Curlie**, but powered by native C execution speed, built-in JSON/header filtering, and environment-aware routing.

## Quick Install

Using standard `curl`:
```sh
curl -fsSL https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
```

Or install `hicurl` using `hicurl` itself:

```sh
hicurl https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
```

> **Why the self-installer works:**
> 1. **Implicit GET:** URLs without an explicit method default to `GET`.
> 
> 2. **Auto-redirects:** `libcurl` automatically follows location redirects (`-L` in cURL).
> 
> 3. **TTY Auto-Detection:** When piped to `sh`, `hicurl` detects a non-TTY stdout stream and outputs clean, uncolored script text without ANSI formatting.
> 

Installs binary (`macos-arm64`, `linux-arm64`, `linux-x86_64`) to `~/.local/bin`. Override target location with `HICURL_INSTALL_DIR=/usr/local/bin`.

```sh
HICURL_INSTALL_DIR=/usr/local/bin curl -fsSL https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
# Or with hicurl
HICURL_INSTALL_DIR=/usr/local/bin hicurl https://github.com/cladam/hicurl/releases/latest/download/install.sh | sh
```

**Note:** _No Windows installer yet_

## Key Features

### Syntax Sugar & Request Builder

* **Flexible Field Parsing:** Positionals dynamically map to headers (`:`), query params (`==`), JSON strings (`=`), raw JSON types (`:=`), file string embedding (`=@`), and file JSON embedding (`:=@`).
* **Localhost Shorthand:** Auto-expands `:8000/v1/health` or `:5000` to `http://localhost:8000/...` for fast local dev.
* **Form Data Toggle (`-f` / `--form`):** Easily switch from default JSON payloads to `application/x-www-form-urlencoded`.
* **Automatic Routing:** Infers implicit `GET` or explicit methods (`post`, `put`, `delete`) effortlessly.

### Native Inspection & Response Filtering

* **Zero-`jq` Dot-Paths:** Filter JSON responses directly with dot notation and array indexing (`.data.users[0].id`).
* **Header & Status Selectors:** Directly extract status codes (`:status`), raw headers (`:headers`), or specific case-insensitive values (`:header.Content-Type`).
* **Cookie Extraction:** Extract session state with `:cookie` or targeted values like `:cookie.session_id`.
* **Latency Diagnostics:** Measure execution times via `libcurl`: `:time` (e.g., `142ms`), `:time.dns`, `:time.connect`, and `:time.ttfb`.

### Workflow, Environments & Safety

* **Environment Base URLs (`-e` / `--env`):** Resolves base URLs from `.hicurl.env`, walking up parent directories automatically.
* **Auth Shortcuts (`-A` / `--auth`):** Built-in support for Bearer tokens (`-A bearer:TOKEN`) and auto-Base64 Basic auth (`-A basic:user:pass`).
* **Offline Dry-Run Mode (`--dry-run`):** Inspect the raw HTTP/1.1 request stream (Method, Path, Headers, Body) without sending any bytes across the wire—inspired by [tbdflow's dry-run design philosophy](https://www.google.com/search?q=https://cladam.github.io/2025/08/23/dry-run/).
* **Code Export (`-E curl`):** Export queries to fully-escaped standard `curl` commands using modern `--url-query` flags.
* **Smart TTY Output:** Colorized ANSI JSON formatting for interactive terminals; clean raw text when redirected or piped.

## Syntax Examples

### Basic Requests & Local Dev

```sh
# Implicit GET
hicurl /users

# Localhost Shorthand (connects to http://localhost:8000/v1/health)
hicurl :8000/v1/health :status

# Query parameters + Response filtering
hicurl get /search query=="hica lang" limit==10 .results

```

### JSON Payloads & File Embedding

```sh
# Explicit POST with mixed JSON types & headers
hicurl post /users name="Alicia" role="admin" age:=28 X-Client-ID:12345

# Embed local text file as JSON string field
hicurl post /post bio=@tests/test_text.txt

# Embed local JSON file directly into request body
hicurl post /post user:=@tests/test_data.json

# Form-encoded POST (application/x-www-form-urlencoded)
hicurl post /oauth/token name="Alicia" age:=30 -f

```

### Auth, Environments & Diagnostics

```sh
# Bearer & Basic Auth Shortcuts
hicurl /v1/me -A bearer:super-secret-token
hicurl /v1/me -A basic:my_user:secret

# Base URL resolution via .hicurl.env
hicurl /posts/1 -e staging

# Latency & Cookie Inspection
hicurl get /heavy-query :time :time.dns :time.ttfb
hicurl post /api/login username=claes password=secret :cookie.session_id

```

### Safety, Exporting & Piping

```sh
# Offline Dry-Run (view raw request without hitting the network)
hicurl post /users name="Alicia" role="admin" --dry-run

# Export to standard cURL command
hicurl post /users name="Sara" age:=52 -E curl

# Command Composition: Query GitHub API, pass URL to nested hicurl query & extract bio
hicurl $(hicurl api.github.com/search/users q==cladam per_page==3 .items.0.url) .bio

```

## Testing & Development

```sh
# Run individual test suites
hica test tests/parser_test.hc
hica test tests/filter_test.hc
hica test tests/auth_test.hc
hica test tests/env_test.hc
hica test tests/export_test.hc

# Run compiled examples
./examples/run_hicurl_examples.sh
```

### Toolchain Commands

```sh
hica build   # Compile to native binary
hica run     # Compile and execute
hica fmt     # Format according to Hica style guide
hica check   # Type-check project
hica clean   # Clean generated build artifacts

```
