#!/bin/bash

# Ensure we exit on error
set -e

# Change directory to the project root directory
cd "$(dirname "$0")/.."

# Check if hicurl binary exists at the root, if not, build it.
if [ ! -f ./hicurl ]; then
  echo "Building hicurl binary..."
  HICA_BIN="hica"
  if ! command -v hica &> /dev/null; then
    HICA_BIN="$HOME/.local/bin/hica"
  fi
  "$HICA_BIN" build src/main.hc -o hicurl
fi

echo "=================================================="
echo " Running hicurl CLI Examples using the compiled binary"
echo "=================================================="

echo -e "\nGET request with query parameters and JSON dot-path filtering"
echo "Command: ./hicurl get https://jsonplaceholder.typicode.com/posts/1 .title"
RESULT=$(./hicurl get https://jsonplaceholder.typicode.com/posts/1 .title)
echo "Output: $RESULT"

echo -e "\nPOST request with JSON string/raw fields and nested filter"
echo "Command: ./hicurl post https://jsonplaceholder.typicode.com/posts title=\"foo\" body=\"bar\" userId:=1 .id"
RESULT=$(./hicurl post https://jsonplaceholder.typicode.com/posts title="foo" body="bar" userId:=1 .id)
echo "Output: $RESULT"

echo -e "\nGET request filtering for Response HTTP Status"
echo "Command: ./hicurl get https://jsonplaceholder.typicode.com/posts/1 :status"
RESULT=$(./hicurl get https://jsonplaceholder.typicode.com/posts/1 :status)
echo "Output: $RESULT"

echo -e "\nGET request filtering for specific Response Header"
echo "Command: ./hicurl get https://jsonplaceholder.typicode.com/posts/1 :header.Content-Type"
RESULT=$(./hicurl get https://jsonplaceholder.typicode.com/posts/1 :header.Content-Type)
echo "Output: $RESULT"

echo -e "\nGET request measuring API Latency"
echo "Command: ./hicurl get https://httpbun.com/delay/1 :time"
RESULT=$(./hicurl get https://httpbun.com/delay/1 :time)
echo "Output: $RESULT"

echo -e "\nGET request inspecting Cookies"
echo "Command: ./hicurl get https://httpbun.com/cookies/set?session_id=abc123xyz :cookie"
RESULT=$(./hicurl get https://httpbun.com/cookies/set?session_id=abc123xyz :cookie)
echo "Output: $RESULT"

echo -e "\nGET request extracting specific Cookie value"
echo "Command: ./hicurl get https://httpbun.com/cookies/set?session_id=abc123xyz :cookie.session_id"
RESULT=$(./hicurl get https://httpbun.com/cookies/set?session_id=abc123xyz :cookie.session_id)
echo "Output: $RESULT"

echo -e "\nGET request with custom headers (Testing HTTP Error gracefully)"
echo "Command: ./hicurl get https://httpbun.com/status/503 .some.field"
RESULT=$(./hicurl get https://httpbun.com/status/503 .some.field)
echo "Output: $RESULT"

echo -e "\nGET request using Localhost URL Shorthand (Exported to curl)"
echo "Command: ./hicurl :8000/v1/health -E curl"
RESULT=$(./hicurl :8000/v1/health -E curl)
echo "Output: $RESULT"

echo -e "\nGET request using Environment Base URL resolution (.hicurl.env)"
echo "Command: ./hicurl -e staging get /posts/1 .title"
RESULT=$(./hicurl -e staging get /posts/1 .title)
echo "Output: $RESULT"

echo -e "\nGET request with Bearer Auth Header Sugar"
echo "Command: ./hicurl -A bearer:super-secret-token get https://httpbun.com/headers .headers.Authorization"
RESULT=$(./hicurl -A bearer:super-secret-token get https://httpbun.com/headers .headers.Authorization)
echo "Output: $RESULT"

echo -e "\nGET request with Basic Auth Header Sugar (Auto-Base64 encoded)"
echo "Command: ./hicurl -A basic:my_user:secret get https://httpbun.com/headers .headers.Authorization"
RESULT=$(./hicurl -A basic:my_user:secret get https://httpbun.com/headers .headers.Authorization)
echo "Output: $RESULT"

echo -e "\nAll examples ran successfully!"
