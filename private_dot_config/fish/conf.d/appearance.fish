status is-interactive || exit

fish_config theme choose catppuccin-macchiato

function update_theme_env --on-variable fish_terminal_color_theme
    set -gx THEME "$fish_terminal_color_theme"

    if test "$THEME" = light
        set -gx BAT_THEME "Catppuccin Latte"
        set -gx DELTA_THEME "catppuccin-latte"
        set -gx FZF_DEFAULT_OPTS "\
            --bind=ctrl-j:accept,ctrl-k:kill-line \
            --color=bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39 \
            --color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
            --color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
            --color=selected-bg:#BCC0CC \
            --color=border:#9CA0B0,label:#4C4F69"
    else
        set -gx BAT_THEME "Catppuccin Macchiato"
        set -gx DELTA_THEME "catppuccin-macchiato"
        set -gx FZF_DEFAULT_OPTS "\
            --bind=ctrl-j:accept,ctrl-k:kill-line \
            --color=bg+:#363A4F,bg:#24273A,spinner:#F4DBD6,hl:#ED8796 \
            --color=fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6 \
            --color=marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796 \
            --color=selected-bg:#494D64 \
            --color=border:#6E738D,label:#CAD3F5"
    end
end

update_theme_env
