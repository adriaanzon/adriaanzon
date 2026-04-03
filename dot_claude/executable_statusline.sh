#!/bin/bash

input=$(cat)

items=()

get_battery_icon() {
    local remaining_int=$1

    local battery_icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

    local level

    if (( remaining_int <= 5 ))
    then
        level=0
    else
        # Slight upward bias for more natural mid/high rounding
        level=$(( (remaining_int * 10 + 60) / 100 ))
    fi

    (( level = level < 0 ? 0 : level > 10 ? 10 : level ))

    echo "${battery_icons[level]}"
}

# Add warning if CLAUDE.md file is missing
if [ ! -f CLAUDE.md ]
then
    items+=("No CLAUDE.md file")
fi

# Add model name
model=$(echo "$input" | jq -r '.model.display_name')
items+=("$model")

# Add current directory name
dirname=$(basename "$PWD")
git_branch=$(git branch --show-current 2>/dev/null)
if [[ -n "$git_branch" ]]
then
    items+=(" $dirname:$git_branch")
else
    items+=(" $dirname")
fi

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')
remaining_int=${remaining%.*}
battery=$(get_battery_icon "$remaining_int")
items+=("$battery $remaining%")

# Add rate limits when either bucket exceeds 25%
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0')
five_hour_int=${five_hour%.*}
seven_day_int=${seven_day%.*}
if (( five_hour_int >= 25 || seven_day_int >= 25 ))
then
    # Clock icon based on 5h reset hour (U+F144B=1 through U+F1456=12)
    resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0')
    reset_hour=$(date -r "$resets_at" +%-I)  # 1-12
    clock_icon=$(python3 -c "print(chr(0xF144A + $reset_hour))")
    items+=("$clock_icon $five_hour_int%  󰭦 $seven_day_int%")
fi

# Output items delimited by box drawing character with padding
printf -v output '  │  %s' "${items[@]}"
echo "${output:5}"
