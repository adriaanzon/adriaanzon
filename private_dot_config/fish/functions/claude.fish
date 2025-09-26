function claude --description 'claude wrapper'
    # Check if ~/.claude.json exists and update theme if needed
    if test -f ~/.claude.json -a -n "$ITERM_THEME"
        set current_theme (jq -r '.theme // empty' ~/.claude.json 2>/dev/null)
        if test "$current_theme" != "$ITERM_THEME"
            jq --arg theme "$ITERM_THEME" '.theme = $theme' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
        end
    end

    command claude $argv
end