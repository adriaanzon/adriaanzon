function fd --description 'fd wrapper that colors output to match the theme'
    if test "$THEME" = light
        LS_COLORS=(vivid --color-mode 8-bit generate catppuccin-latte) command fd $argv
    else
        LS_COLORS=(vivid --color-mode 8-bit generate catppuccin-macchiato) command fd $argv
    end
end
