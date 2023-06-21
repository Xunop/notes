#!/bin/bash

git checkout main
git diff HEAD^ HEAD --name-only
files=$(git diff HEAD^ HEAD --name-only)
echo "files: $files"

# Read the .fignore file
while read line; do
  # Ignore lines that start with "#" or are empty
  if [[ $line == \#* ]] || [[ -z $line ]]; then
    continue
  fi
  # Ignore the file
  ignore_list+=("$line")
done < .fignore

echo "ignore_list: ${ignore_list[@]}"
for file in $files
do
  # Ignore files in the ignore list
  if [[ " ${ignore_list[@]} " =~ "$file" ]]; then
    echo "Ignoring file: $file"
    continue
  fi
  
  echo "Formatting file: $file"
  #/bin/bash ../my_scripts/format.sh -f "$file"
done
