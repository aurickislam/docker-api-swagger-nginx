#!/bin/sh
# Called by IntelliJ File Watcher with $FilePath$ as argument
FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

case "$FILE" in
    *.gz) exit 0 ;;
esac

SIZE=$(wc -c < "$FILE")
if [ "$SIZE" -gt 1024 ]; then
    gzip -k -f -6 "$FILE"
#    echo "Compressed: $FILE"
#else
#    echo "Skipped (< 1KB): $FILE"
fi
