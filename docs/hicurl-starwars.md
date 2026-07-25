### 1. Basic GET & Single Field Filtering

Fetch Luke Skywalker (`people/1`) and directly extract his name using dot-path syntax, bypassing raw JSON output or `jq`.

```sh
hicurl swapi.dev/api/people/1 .name
```

**Output:**

```
Luke Skywalker
```

### 2. Query Parameters & Array Index Extraction

Search for characters with the name "Skywalker" using the `==` query parameter operator, then extract the birth year of the first result.

```sh
hicurl swapi.dev/api/people/ search=="skywalker" .results[0].birth_year
```

**Output:**

```
19BBY
```

### 3. Response Latency & Time-To-First-Byte (TTFB) Diagnostics

Measure the execution latency when querying planet details for Tatooine (`planets/1`).

```sh
hicurl swapi.dev/api/planets/1 :time :time.ttfb
```

**Output:**

```
184ms
142ms
```

### 4. HTTP Status Code & Header Extraction

Inspect the HTTP status code and server `Content-Type` header when fetching the first Star Wars film.

```sh
hicurl swapi.dev/api/films/1 :status :header.content-type
```

**Output:**

```
200
application/json; charset=utf-8
```

### 5. Safe Offline Inspection (`--dry-run`)

Inspect the raw HTTP/1.1 request stream generated for the Millennium Falcon (`starships/10/`) without firing bytes over the network.

```sh
hicurl swapi.dev/api/starships/10/ --dry-run
```

**Output:**

```http
GET /api/starships/10/ HTTP/1.1
Host: swapi.dev
User-Agent: hicurl/0.5.0
Accept: */*
```

### 6. Exporting SWAPI Queries to Standard `curl`

Construct a complex query for vehicles and export it into a shareable `curl` command using modern `--url-query` flags.

```sh
hicurl swapi.dev/api/vehicles/ search=="speeder" page==1 -E curl
```

**Output:**

```sh
curl -sS --url-query "search=speeder" --url-query "page=1" "https://swapi.dev/api/vehicles/"
```

### 7. Command Composition (Nested Subshell Queries)

Query Luke Skywalker's homeworld URL, pass that URL into a second `hicurl` execution, and extract the homeworld's name (Tatooine).

```sh
hicurl $(hicurl swapi.dev/api/people/1 .homeworld) .name
```

**Output:**

```
Tatooine
```