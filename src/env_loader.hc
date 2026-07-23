import "std/io"

pub fun resolve_url(url: string, env_opt: maybe<string>) : string {
  match env_opt {
    None => url,
    Some(env_name) => {
      let content_res = match read_file(".hicurl.env") {
        Ok(c) => Ok(c),
        Err(_) => read_file("../.hicurl.env")
      }
      match content_res {
        Err(_) => url,
        Ok(content) => {
          let base_url = find_env_url(lines(content), env_name)
          match base_url {
            None => url,
            Some(base) => {
              if starts_with(url, "http://") || starts_with(url, "https://") {
                url
              } else {
                let clean_base = if ends_with(base, "/") { base } else { base + "/" }
                let clean_url = if starts_with(url, "/") { url[1:] } else { url }
                clean_base + clean_url
              }
            }
          }
        }
      }
    }
  }
}

pub fun find_env_url(line_list: list<string>, target_env: string) : maybe<string> =>
  match line_list {
    [] => None,
    [l, ..rest] => {
      let trimmed = trim(l)
      if starts_with(trimmed, "#") || is_empty(trimmed) {
        find_env_url(rest, target_env)
      } else {
        let split_char = if contains(trimmed, "=") { "=" } else { ":" }
        match index_of(trimmed, split_char) {
          None => find_env_url(rest, target_env),
          Some(idx) => {
            let key = trim(trimmed[0:idx])
            let val = trim(trimmed[idx+1:])
            if to_lower(key) == to_lower(target_env) {
              Some(val)
            } else {
              find_env_url(rest, target_env)
            }
          }
        }
      }
    }
  }
