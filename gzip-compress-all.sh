#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWAGGER_DIR="$SCRIPT_DIR/swagger-ui"

find "$SWAGGER_DIR" -size +1k ! -name '*.gz' | grep -E '[.](yaml|yml|js|css|html)$' | while read -r FILE; do
    "$SCRIPT_DIR/gzip-compress.sh" "$FILE"
done
