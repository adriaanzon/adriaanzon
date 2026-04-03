function claude --description 'claude wrapper'
    # Check if ~/.claude.json exists and update theme if needed
    if test -f ~/.claude.json -a -n "$THEME"
        set current_theme (jq -r '.theme // empty' ~/.claude.json 2>/dev/null)
        if test "$current_theme" != "$THEME"
            jq --arg theme "$THEME" '.theme = $theme' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
        end
    end

    #set -lx DISABLE_AUTOUPDATER 1

    command claude $argv
end
