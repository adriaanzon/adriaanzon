function _set_light_theme --description 'Set colors for the Snow Day theme'
    if test "$_current_theme" = light
        return
    end
    set -g _current_theme light

    set -g fish_color_normal normal
    set -g fish_color_command 164CC9
    set -g fish_color_quote 4C3499
    set -g fish_color_redirection 248E8E
    set -g fish_color_end 02BDBD
    set -g fish_color_error 9177E5
    set -g fish_color_param 4319CC
    set -g fish_color_comment 007B7B
    set -g fish_color_match --background=brblue
    set -g fish_color_selection white --bold --background=brblack
    set -g fish_color_search_match bryellow --background=brblack
    set -g fish_color_history_current --bold
    set -g fish_color_operator 00a6b2
    set -g fish_color_escape 00a6b2
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_valid_path --underline
    set -g fish_color_autosuggestion 7596E4
    set -g fish_color_user brgreen
    set -g fish_color_host normal
    set -g fish_color_cancel -r
    set -g fish_pager_color_completion normal
    set -g fish_pager_color_description B3A06D yellow
    set -g fish_pager_color_prefix white --bold --underline
    set -g fish_pager_color_progress brwhite --background=cyan

    set -gx BAT_THEME GitHub
end
