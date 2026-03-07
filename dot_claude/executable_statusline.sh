#!/bin/bash

input=$(cat)

items=()

# Add warning if CLAUDE.md file is missing
if [ ! -f CLAUDE.md ]
then
    if [ -f artisan ]
    then
        # Add an extra visual indicator in directories that should have a CLAUDE.md file
        items+=("⚠️ No CLAUDE.md file")
    else
        items+=("No CLAUDE.md file")
    fi
fi

# Add model name if not Sonnet
model=$(echo "$input" | jq -r '.model.display_name')
if [[ ! "$model" =~ [Ss]onnet ]]; then
    items+=("🧠 $model")
fi

# Add current directory name
dirname=$(basename "$PWD")
git_branch=$(git branch --show-current 2>/dev/null)
if [[ -n "$git_branch" ]]
then
    items+=("📂 $dirname:$git_branch")
else
    items+=("📂 $dirname")
fi

# Output items delimited by box drawing character with padding
printf -v output '  │  %s' "${items[@]}"
# Remove first 5 characters ('  │  ') from the output
echo "${output:5}"
