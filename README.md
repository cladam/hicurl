# hicurl

A modern HTTP CLI built in Hica with a rich feature set and intuitive syntax sugar.

## Completed Features

- **Base CLI Parser**: Configured via `std/cli` with options for `--auth` (`-A`), `--env` (`-e`), and `--export` (`-E`).
- **Flexible Syntax Sugar**: Positionals are dynamically parsed into headers (`:`), query parameters (`==`), JSON string fields (`=`), JSON raw fields (`:=`), and response filters (`.` / `:status` / `:headers`).
- **Automatic Method & URL Routing**: Correctly infers implicit `GET` or explicit methods (`post`, `put`, `delete`, etc.) and handles positional routing.
- **HTTP Execution**: Fully integrated HTTP client engine utilizing `libcurl` via Koka FFI to execute GET, POST, and other HTTP requests with the parsed headers, query parameters, and custom JSON bodies.
- **Response Filtering**: Rich response filters supporting Status Codes (`:status`), Raw Headers (`:headers`), case-insensitive specific header values (`:header.Header-Name`), and nested JSON dot-path navigation including array indexing (e.g. `.path.to.field` or `.[0].name`).

## Syntax Examples (Currently Parsed)

```sh
# Implicit GET
hicurl /users

# Explicit POST with JSON body and custom Header
hicurl post /users name="Alice" role="admin" age:=28 X-Client-ID:12345

# GET with query params and response filter
hicurl get /search query=="hica lang" limit==10 .results
```

## Running Tests

To run the parser test suite:

```sh
../hica-ecosystem/hica/hica test tests/parser_test.hc
```

To run the response filter test suite:

```sh
../hica-ecosystem/hica/hica test tests/filter_test.hc
```

## Toolchain Development commands

```sh
hica build   # compile to binary
hica run     # compile and run
hica fmt     # format according to hica style guide
hica check   # type-check without emitting
hica clean   # remove generated files
```
