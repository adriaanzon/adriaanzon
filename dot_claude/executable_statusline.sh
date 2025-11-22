#!/bin/bash

input=$(cat)

items=()

# Add warning if CLAUDE.md file is missing
if [ ! -f CLAUDE.md ]
then
    items+=("⚠️ No CLAUDE.md file")
fi

# Add model name if not Sonnet
model=$(echo "$input" | jq -r '.model.display_name')
if [[ ! "$model" =~ [Ss]onnet ]]; then
    items+=("🧠 $model")
fi

# Add current directory name
items+=("📂 $(basename "$PWD")")

# Output items delimited by box drawing character with padding
printf -v output '  │  %s' "${items[@]}"
# Remove first 5 characters ('  │  ') from the output
echo "${output:5}"
