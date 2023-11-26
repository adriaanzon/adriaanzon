setlocal wrap

" https://github.com/tpope/vim-markdown/issues/21
highlight link markdownError NONE
augroup ResetMarkdownHl
    autocmd!
    autocmd ColorScheme <buffer> highlight link markdownError NONE
augroup END
