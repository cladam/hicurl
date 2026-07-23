import "../src/env_loader"

test "find env url from lines" {
  let env_lines = [
    "# This is a comment",
    "staging=https://api.staging.example.com",
    "prod: https://api.example.com",
    "  dev = https://api.dev.example.com  "
  ]
  
  assert(find_env_url(env_lines, "staging") == Some("https://api.staging.example.com"))
  assert(find_env_url(env_lines, "prod") == Some("https://api.example.com"))
  assert(find_env_url(env_lines, "dev") == Some("https://api.dev.example.com"))
  assert(find_env_url(env_lines, "local") == None)
}
