" Feature: Appearance

set termguicolors

" Clear search highlighting when pressing Escape in normal mode.
nnoremap <Esc> :nohlsearch <Bar> echo<CR>

" Press Space-C to fix issues related to coloring.
nnoremap <Space>c :set synmaxcol=3000 <Bar> call appearance#DetectColorScheme()<CR>

function! appearance#DetectColorScheme()
    let l:result = systemlist(['defaults', 'read', '-g', 'AppleInterfaceStyle'])[0]

    call s:SetColorScheme(l:result is# 'Dark' ? 'dark' : 'light')
endfunction

function! s:SetColorScheme(theme)
    let &background = a:theme

    if a:theme is# 'dark'
        colorscheme nord
        highlight Normal guibg=NONE ctermbg=NONE
    else
        colorscheme github
    endif

    " Fix coc.nvim highlight color
    highlight! link CocMenuSel PmenuSel
endfunction

" On startup, set the color scheme based on the $ITERM_THEME universal
" variable in Fish. This variable is used, so the `defaults` command doesn't
" have to be run on startup which could hurt performance.
if !empty($ITERM_THEME)
    call s:SetColorScheme($ITERM_THEME)
endif
