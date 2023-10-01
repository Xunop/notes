#!/bin/bash

git checkout main
update_files=$(git diff HEAD^ HEAD --name-only --diff-filter=d)
del_files=$(git diff HEAD^ HEAD --diff-filter=D --name-only)

#set -x
# Determine .fileignore file if updated
if [[ $(echo $update_files | grep .fignore) ]]; then
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
                                echo ".fignore del file: $line"
                                update_files+=($line)
                        # filename
                        else
                                u_files=$(find -name "$line.*")
                                update_files+=($u_files)
                        fi
                done
        fi
fi
#set +x

echo "Deleted files: "
echo "${del_files[@]}"
echo "---------------------"
if [[ $del_files ]]; then
        for file in "${del_files[@]}"; do
                echo "Deleting file: $file"
                /bin/bash ../my_scripts/format.sh -d "$file"
        done
fi

echo "Updated files: "
echo "${update_files[@]}"
echo "---------------------"
# Read the .fignore file
while read line; do
        # Ignore lines that start with "#" or are empty
        if [[ $line == \#* ]] || [[ -z $line ]]; then
          continue
        fi
        if [[ $line =~ .*/\*$ ]]; then
                for f in $line; do
                        f=$(echo $f)
                        ignore_list+=("$f")
                done
                continue
        fi
                
        # Ignore the file
        ignore_list+=("$line")
done < .fignore

for ifile in "${ignore_list[@]}"; do
        echo "ignore_list: $ifile"
done

sleep 1

files=$(echo "${update_files[@]}" | tr '\n' ' ')

IFS=' ' read -r -a files <<< "${files[@]}"
#set -x
for file in "${files[@]}";
do
        # Ignore files that match any pattern in the ignore list
        for pattern in "${ignore_list[@]}"; do
                if [[ $file == $pattern ]]; then
                        echo "Ignoring file: $file"
                        continue 2
                fi
                name=$(basename "$file")
                if [[ $name == $pattern ]]; then
                        echo "Ignoring file: $file"
                        continue 2
                fi
        done
        echo "Formatting file: $file"
        /bin/bash ../my_scripts/format.sh -f "$file"
done

# Itersate over all files in the repo
for file in $(find . -type f -not -path '*/\.*' -not -path './.fignore' -not -path './.git/*' -name flush);
do
        echo "---------FLUSH-----------"
        filename="${file#./}"
        echo "Flush file: $file"

        content=$(cat $file)
        if [[ $content != "flush" ]]; then
                echo "Flush file content is not 1"
                continue
        fi

        flush_dir=$(dirname $file)
        # Ignore files that match any pattern in the ignore list
        for pattern in "${ignore_list[@]}"; do
                if [[ $filename == $pattern ]]; then
                        echo "Ignoring file: $file"
                        continue 2
                fi
                name=$(basename $file)
                if [[ $name == $pattern ]]; then
                        echo "Ignoring file: $file"
                        continue 2
                fi
        done

        for f in $flush_dir/*; do
                echo "Formatting file: $f"
                if [[ -f $f ]]; then
                        /bin/bash ../my_scripts/format.sh -f "$f" --force
                fi
        done
done
