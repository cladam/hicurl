// Demo of the cli prelude: pipe-friendly builders, subcommands,
// combined short flags, typed options, positional access, and defaults.
//
// Usage:
//   ./hica run examples/cli-prelude.hc -- --help
//   ./hica run examples/cli-prelude.hc -- --verbose --output out.txt data.txt
//   ./hica run examples/cli-prelude.hc -- -vf csv data.txt
//   ./hica run examples/cli-prelude.hc -- -vo out.txt data.txt
//   ./hica run examples/cli-prelude.hc -- check --strict src/

import "std/cli"

fun make_get_spec() =>
  cli("hicurl get", "0.1.0", "run a get command")
    |> arg("URL", "URL to query", true)

fun make_post_spec() =>
  cli("hicurl post", "0.1.0", "run a post command")
    |> arg("URL", "URL to post data towards", true)

fun make_spec() =>
  cli("hicurl", "0.1.0", "a modern HTTP CLI")
    |> flag("verbose", "v", "enable verbose output")
    |> command("get", make_get_spec())
    |> command("post", make_post_spec())

fun main() {
  let spec = make_spec()
  match cli_parse(spec) {
    Help          => println(cli_help(spec)),
    Version       => println(cli_version_str(spec)),
    CliError(msg) => eprintln("error: {msg}"),
    Parsed(r)     => {
      if has_flag(r, "verbose") { println("verbose mode is ON") }
      match get_sub(r) {
        Some(sub) => {
          println("subcommand: {get_command(r)}")
          println("  URL: {show(get_positionals(sub))}")
        },
        None => println("")
      }
    }
  }
}
