import "std/cli"

pub fun make_spec() =>
  cli("hicurl", "0.5.0", "hicurl - a modern HTTP CLI")
    |> flag("verbose", "v", "Enable verbose output")
    |> option("auth", "A", "Quick auth sugar (bearer, basic)")
    |> option("env", "e", "Select environment from .hicurl.env")
    |> option("export", "E", "Export code instead of executing (hica, curl)")
