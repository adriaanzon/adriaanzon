" Feature: Completion, language server and other smart expansion stuff

set number
set pumheight=12
set signcolumn=number

inoremap <silent><expr> <CR> <SID>SuperCR()
function! s:SuperCR()
    if pumvisible() && !empty(v:completed_item)
        return "\<C-y>"
    endif

    if index(g:bullets_enabled_file_types, &filetype) != -1 && col('$') == col('.')
        return "\<Esc>:InsertNewBullet\<CR>"
    endif

    return "\<CR>"
endfunction

" Abbreviations for Ex-commands
abbreviate qw wq
