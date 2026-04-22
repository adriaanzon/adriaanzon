#!/bin/zsh --ksharrays

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

# Add model name
model=$(echo "$input" | jq -r '.model.display_name')
items+=("$model")

# Warning icon if CLAUDE.md is missing
guidelines_missing_icon=""
if [ ! -f CLAUDE.md ]
then
    guidelines_missing_icon="  󱀶"
fi

# Add current directory name
dirname=$(basename "$PWD")
git_branch=$(git branch --show-current 2>/dev/null)
if [[ -n "$git_branch" ]]
then
    items+=(" $dirname:$git_branch$guidelines_missing_icon")
else
    items+=(" $dirname$guidelines_missing_icon")
fi

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')
remaining_int=${remaining%.*}
battery=$(get_battery_icon "$remaining_int")
tokens_used=$(echo "$input" | jq -r '(.context_window.current_usage // {}) | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))')
if (( tokens_used > 0 ))
then
    items+=("$battery $(( tokens_used / 1000 ))k")
fi

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
    clock_icon=${(#)$(( 0xF144A + reset_hour ))}
    items+=("$clock_icon $five_hour_int%  󰭦 $seven_day_int%")
fi

# Output items delimited by box drawing character with padding
printf -v output '  │  %s' "${items[@]}"
echo "${output:5}"
