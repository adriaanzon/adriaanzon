" Feature: Completion, language server and other smart expansion stuff

set number
set pumheight=12
set signcolumn=number

inoremap <silent><expr> <CR> <SID>SuperCR()
function! s:SuperCR()
    if coc#pum#visible()
        return coc#pum#confirm()
    endif

    if pumvisible() && !empty(v:completed_item)
        return "\<C-y>"
    endif

    call coc#on_enter()

    if index(g:bullets_enabled_file_types, &filetype) != -1 && col('$') == col('.')
        return "\<Esc>:InsertNewBullet\<CR>"
    endif

    return "\<CR>"
endfunction

inoremap <silent><expr> <C-Space> coc#refresh()

nnoremap <silent><nowait> <Space>o :<C-u>CocList -I symbols<CR>
nnoremap <silent><nowait> <Space>O :<C-u>CocList files<CR>
nnoremap <silent><nowait> <Space>e :<C-u>CocList mru<CR>
nnoremap <silent><nowait> <Space>F :<C-u>CocList grep<CR>

nmap <M-CR> <Plug>(coc-codeaction-cursor)
nmap <D-b> <Plug>(coc-definition)

" Abbreviations for Ex-commands
abbreviate qw wq
