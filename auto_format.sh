#!/bin/bash

git checkout main
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
  # Ignore files that match any pattern in the ignore list
  for pattern in "${ignore_list[@]}"; do
    if [[ $file == $pattern ]]; then
      echo "Ignoring file: $file"
      continue 2
    fi
    name=$(basename $file)
    if [[ $name == $pattern ]]; then
      echo "Ignoring file: $file"
      continue 2
    fi
    echo "Formatting file: $file"
    /bin/bash ../my_scripts/format.sh -f "$file"
  done
done
