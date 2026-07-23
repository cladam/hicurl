#!/bin/bash

# Ensure we exit on error
set -e

# Change directory to the examples directory if we aren't already there
cd "$(dirname "$0")"

# Check if hicurl binary exists at the root, if not, build it.
if [ ! -f ../hicurl ]; then
  echo "Building hicurl binary..."
  ../hica-ecosystem/hica/hica build ../src/main.hc -o ../hicurl
fi

echo "=================================================="
echo " Running hicurl CLI Examples using the compiled binary"
echo "=================================================="

echo -e "\nGET request with query parameters and JSON dot-path filtering"
echo "Command: ../hicurl get https://jsonplaceholder.typicode.com/posts/1 .title"
RESULT=$(../hicurl get https://jsonplaceholder.typicode.com/posts/1 .title)
echo "Output: $RESULT"

echo -e "\nPOST request with JSON string/raw fields and nested filter"
echo "Command: ../hicurl post https://jsonplaceholder.typicode.com/posts title=\"foo\" body=\"bar\" userId:=1 .id"
RESULT=$(../hicurl post https://jsonplaceholder.typicode.com/posts title="foo" body="bar" userId:=1 .id)
echo "Output: $RESULT"

echo -e "\nGET request filtering for Response HTTP Status"
echo "Command: ../hicurl get https://jsonplaceholder.typicode.com/posts/1 :status"
RESULT=$(../hicurl get https://jsonplaceholder.typicode.com/posts/1 :status)
echo "Output: $RESULT"

echo -e "\nGET request filtering for specific Response Header"
echo "Command: ../hicurl get https://jsonplaceholder.typicode.com/posts/1 :header.Content-Type"
RESULT=$(../hicurl get https://jsonplaceholder.typicode.com/posts/1 :header.Content-Type)
echo "Output: $RESULT"

echo -e "\nGET request with custom headers (Testing HTTP Error gracefully)"
echo "Command: ../hicurl get https://httpbin.org/status/503 .some.field"
RESULT=$(../hicurl get https://httpbin.org/status/503 .some.field)
echo "Output: $RESULT"

echo -e "\nGET request using Environment Base URL resolution (.hicurl.env)"
echo "Command: ../hicurl -e staging get /posts/1 .title"
RESULT=$(../hicurl -e staging get /posts/1 .title)
echo "Output: $RESULT"

echo -e "\nGET request with Bearer Auth Header Sugar"
echo "Command: ../hicurl -A bearer:super-secret-token get https://httpbin.org/headers .headers.Authorization"
RESULT=$(../hicurl -A bearer:super-secret-token get https://httpbin.org/headers .headers.Authorization)
echo "Output: $RESULT"

echo -e "\nGET request with Basic Auth Header Sugar (Auto-Base64 encoded)"
echo "Command: ../hicurl -A basic:my_user:secret get https://httpbin.org/headers .headers.Authorization"
RESULT=$(../hicurl -A basic:my_user:secret get https://httpbin.org/headers .headers.Authorization)
echo "Output: $RESULT"

echo -e "\nAll examples ran successfully!"
