import "std/cli"

pub fun make_spec() =>
  cli("hicurl", "0.6.2", "hicurl - a modern HTTP CLI")
    |> flag("verbose", "v", "Enable verbose output")
    |> flag("form", "f", "Serialize data items as form values")
    |> option("auth", "A", "Quick auth sugar (bearer, basic)")
    |> option("env", "e", "Select environment from .hicurl.env")
    |> option("export", "E", "Export code instead of executing (hica, curl, http)")
    |> flag("dry-run", "", "Offline dry-run (print raw HTTP request stream)")

pub fun cli_help_extended(spec) {
  let base_help = cli_help(spec)
  let extra_help = "SYNTAX SUGARS:\n" +
"  [METHOD] URL          Explicit or implicit GET method, followed by the URL or path.\n" +
"  Header:Value          Add custom request headers.\n" +
"  key==value            Add URL query parameters.\n" +
"  key=value             Add string field to JSON request body.\n" +
"  key:=value            Add raw JSON (number, bool, array, object) to request body.\n" +
"  key=@file.txt         Add string field with contents of file.txt to JSON request body.\n" +
"  key:=@file.json       Add raw JSON field with contents of file.json to JSON request body.\n\n" +
"FILTERS & DIAGNOSTICS:\n" +
"  .path.to.field        Filter response body using dot-path notation (supports array index: .[0]).\n" +
"  :status               Print response HTTP status code.\n" +
"  :headers              Print all response headers.\n" +
"  :header.Name          Print value of a specific response header.\n" +
"  :cookies              Print all received cookies.\n" +
"  :cookie.Name          Print value of a specific received cookie.\n" +
"  :time                 Print total execution/response time.\n" +
"  :time.[dns|connect|ttfb] Print DNS lookup, TCP connection, or TTFB timing breakdowns.\n\n" +
"EXAMPLES:\n" +
"  hicurl /users\n" +
"  hicurl post /users name=\"Alicia\" role=\"admin\" age:=28\n" +
"  hicurl get /search query==\"hica lang\" limit==10 .results\n" +
"  hicurl /v1/me -A bearer:super-secret-token\n" +
"  hicurl /posts/1 -e staging\n" +
"  hicurl post /users name=\"Sara\" age:=52 -E curl\n" +
"  hicurl post /users name=\"Alicia\" role=\"admin\" --dry-run\n" +
"  hicurl get /heavy-query :time :time.dns :time.ttfb\n" +
"  hicurl post /api/login username=cladam password=secret :cookie.session_id\n"
  base_help + "\n" + extra_help
}
