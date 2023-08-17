#!/bin/bash

git checkout main
files=$(git diff HEAD^ HEAD --name-only)

#set -x
# Determine .fileignore file if updated
if [[ $(echo $files | grep .fignore) ]]; then
        echo ".fignore file updated"
        # Get the hash of the last two commit that modified .fignore
        latest_commit=$(git log -1 --pretty=format:%H)
        previous_commit=$(git log -2 --pretty=format:%H | tail -n 1)
        # If content has changed, check for specific changes
        diff_output=$(git diff $latest_commit_hash $previous_commit .fignore)
        if echo "$diff_output" | grep -E "^-[^-]" >/dev/null; then
                del_lines=$(echo "$diff_output" |
                            grep "^-[^-]"       |
                            sed '/^-/s/^-//'    |
                            sed '/^#/d')
                echo "File .fignore has deleted lines: $del_lines"
                # Judge del_lines is file or dir
                for line in $del_lines; do
                        # /dir/*
                        if [[ -f $line ]]; then
                                echo "del file: $line"
                                files+=($line)
                        # filename
                        else
                                u_files=$(find -name "$line.*")
                                files+=($u_files)
                        fi
                done
        fi
fi
#set +x

echo "Updated files: "
echo "${files[@]}"
echo "---------------------"
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
for file in "${files[@]}";
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
        /bin/bash ../my_scripts/format.sh -f "$file"
done
