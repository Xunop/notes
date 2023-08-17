#!/bin/bash

git checkout main
files=$(git diff HEAD^ HEAD --name-only)
echo "[INFO] new files: $(echo $files | awk '{print}')"

set -x
# Determine .fileignore file if updated
if [[ $(echo $files | grep .fignore) ]]; then
        echo "[INFO] .fignore file updated"
        # Get the hash of the last commit that modified .fignore
        last_commit_hash=$(git log -1 --pretty=format:%H -- .fignore)
        # If content has changed, check for specific changes
        diff_output=$(git diff $last_commit_hash .fignore)
        if echo "$diff_output" | grep -E "^\-" >/dev/null; then
                echo "File .fignore has deleted lines:"
                echo "$diff_output" | grep "^\-"
                del_lines = $("$diff_output" | grep "^\-")
        fi
fi

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
#set -x
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
        done
        echo "Formatting file: $file"
        # /bin/bash ../my_scripts/format.sh -f "$file"
done
