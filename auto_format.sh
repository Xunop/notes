#!/bin/sh

git checkout main
git diff HEAD^ HEAD --name-only
files=$(git diff HEAD^ HEAD --name-only)
echo "files: $files"

for file in $files
do
  /bin/bash ../my_scripts/format.sh -f "$file"
done
