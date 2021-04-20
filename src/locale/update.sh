#!/bin/sh

DIR="$(dirname $0)"

FILES="$(ls ${DIR}/*.po)"

pybabel extract -F "${DIR}/../../babelrc" -k text -k LineEdit/placeholder_text -k tr -o "${DIR}/en.po" "${DIR}/../../"

for FILE in $FILES; do
    msgmerge --update --backup=none $FILE en.po
done
