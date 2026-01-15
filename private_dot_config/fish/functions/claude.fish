function claude --description 'claude wrapper'
    # Check if ~/.claude.json exists and update theme if needed
    if test -f ~/.claude.json -a -n "$ITERM_THEME"
        set current_theme (jq -r '.theme // empty' ~/.claude.json 2>/dev/null)
        if test "$current_theme" != "$ITERM_THEME"
            jq --arg theme "$ITERM_THEME" '.theme = $theme' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
        end
    end

    # Disable auto-updater to pin the version to 2.0.50, which doesn't run out of usage quota as quickly
    set -lx DISABLE_AUTOUPDATER 1

    command claude $argv
end
