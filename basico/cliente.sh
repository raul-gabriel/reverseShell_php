#!/bin/bash
URL="URL"

while true; do
    echo -n "$ "
    read cmd
    [ "$cmd" = "exit" ] && break
    curl -s -X POST "$URL" -H "Content-Type: application/json" \
         -d "{\"cmd\":\"$cmd\"}" | jq -r '.output'
done
