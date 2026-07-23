import "std/cli"

pub fun make_spec() =>
  cli("hicurl", "0.4.0", "hicurl - a modern HTTP CLI")
    |> option("auth", "A", "Quick auth sugar (bearer, basic)")
    |> option("env", "e", "Select environment from .hicurl.env")
    |> option("export", "E", "Export code instead of executing (hica, curl)")
