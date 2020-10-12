#!/bin/sh

DIR="$(dirname $0)"
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 LOCALE"
    echo "Example: $0 de"
fi

msginit --no-translator --input="$DIR/en.po" --locale="$1"
