status is-interactive || exit

fish_config theme choose catppuccin-macchiato

function update_theme_env --on-variable fish_terminal_color_theme
    set -gx THEME "$fish_terminal_color_theme"
    set -gx BAT_THEME (test "$THEME" = light && echo "Catppuccin Latte" || echo "Catppuccin Macchiato")
    set -gx DELTA_THEME (test "$THEME" = light && echo "catppuccin-latte" || echo "catppuccin-macchiato")
end

update_theme_env
