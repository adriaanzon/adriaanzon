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

dirname=$(basename "$PWD")
git_branch=$(git branch --show-current 2>/dev/null)
tokens_used=$(echo "$input" | jq -r '(.context_window.current_usage // {}) | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))')
five_hour_limit=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
seven_day_limit=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0')
five_hour_limit_int=${five_hour_limit%.*}
seven_day_limit_int=${seven_day_limit%.*}

# Add model name
model=$(echo "$input" | jq -r '.model.display_name')
items+=("$model")

# Warning icon if CLAUDE.md is missing
guidelines_missing_icon=""
if [ ! -f CLAUDE.md ]
then
    guidelines_missing_icon="  󱀶"
    if (( tokens_used == 0 ))
    then
        guidelines_missing_icon="$guidelines_missing_icon No CLAUDE.md file"
    fi
fi

# Add current directory name
if [[ -n "$git_branch" ]]
then
    items+=(" $dirname:$git_branch$guidelines_missing_icon")
else
    items+=(" $dirname$guidelines_missing_icon")
fi

if (( tokens_used > 0 ))
then
    # Rebase against the point where context drift sets in, not the actual
    # context window: ~200k for Opus 4.7/4.8; ~400k for Fable 5 (drifts later,
    # ~30% denser tokenizer).
    case $model in
        (*Fable*|*Mythos*) effective_limit=400000 ;;
        (*) effective_limit=200000 ;;
    esac
    remaining_int=$(( 100 - (tokens_used * 100 / effective_limit) ))
    (( remaining_int < 0 )) && remaining_int=0
    battery=$(get_battery_icon "$remaining_int")
    items+=("$battery $(( tokens_used / 1000 ))k")
fi

# Add rate limits when either bucket exceeds 25%
if (( five_hour_limit_int >= 25 || seven_day_limit_int >= 25 ))
then
    # Clock icon based on 5h reset hour (U+F144B=1 through U+F1456=12)
    resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0')
    reset_hour=$(date -r "$resets_at" +%-I)  # 1-12
    clock_icon=${(#)$(( 0xF144A + reset_hour ))}
    items+=("$clock_icon $five_hour_limit_int%  󰭦 $seven_day_limit_int%")
fi

# Output items delimited by box drawing character with padding
printf -v output '  │  %s' "${items[@]}"
echo "${output:5}"
