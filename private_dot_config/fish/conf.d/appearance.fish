status is-interactive || exit

fish_config theme choose adriaan

function update_theme_env --on-variable fish_terminal_color_theme
    set -gx THEME (test "$fish_terminal_color_theme" = light && echo light || echo dark)
    set -gx BAT_THEME (test "$fish_terminal_color_theme" = light && echo GitHub || echo Nord)
end

update_theme_env
