#!/bin/sh

git checkout main
files=$(git diff HEAD^ HEAD --name-only | awk '{print $2}')
echo "files: $files"

for file in $files
do
  ../my_scripts/format.sh -f "$file"
done
