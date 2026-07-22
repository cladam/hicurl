import "std/cli"
import "../src/parser"

fun main() {
  let spec = make_spec()
  println(cli_help(spec))
}
