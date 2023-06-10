#!/bin/sh

git checkout main
git status --short
files=$(git status --short | awk '{print $2}')
echo "files: $files"

for file in $files
do
  ../my_scripts/format.sh -f "$file"
done
