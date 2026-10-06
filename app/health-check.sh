#!/bin/bash

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for cmd in df free getent hostname uname; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "UNHEALTHY: missing dependency '$cmd'" >&2
        exit 1
    fi
done

if ! "$DIR/diagnostic.sh" help >/dev/null 2>&1; then
    echo "UNHEALTHY: diagnostic.sh help failed" >&2
    exit 1
fi

echo "HEALTHY"
exit 0
