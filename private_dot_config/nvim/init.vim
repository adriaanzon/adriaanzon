" See also settings that are structured by feature in the "plugin" folder.

set autoindent expandtab shiftwidth=4
set foldlevelstart=99
set hidden
set ignorecase smartcase
set linebreak nowrap showbreak=\ ↳
set mouse=a
set nojoinspaces
set spelllang=en,nl
set splitbelow splitright
set title

nnoremap <Space>o :only<CR>
nnoremap c# #NcgN
nnoremap c* *Ncgn
nnoremap N Nzz
nnoremap n nzz
nnoremap Y y$

"
" Plugin-specific settings
"

let g:mapleader = "\<Space>"

" Bullets configuration. Note that the <CR> mapping is removed as Bullets is
" already supported by my SuperCR mapping.
let g:bullets_nested_checkboxes = 0
let g:bullets_renumber_on_change = 0
let g:bullets_set_mappings = 0
let g:bullets_custom_mappings = [
\   ['inoremap', '<C-CR>', '<CR>'],
\   ['nmap', 'o', '<Plug>(bullets-newline)'],
\   ['vmap', 'gN', '<Plug>(bullets-renumber)'],
\   ['nmap', 'gN', '<Plug>(bullets-renumber)'],
\   ['nmap', '<Leader>x', '<Plug>(bullets-toggle-checkbox)'],
\   ['imap', '<C-t>', '<Plug>(bullets-demote)'],
\   ['nmap', '>>', '<Plug>(bullets-demote)'],
\   ['vmap', '>', '<Plug>(bullets-demote)'],
\   ['imap', '<C-d>', '<Plug>(bullets-promote)'],
\   ['nmap', '<<', '<Plug>(bullets-promote)'],
\   ['vmap', '<', '<Plug>(bullets-promote)'],
\]

packadd chezmoi.vim

let g:html_no_rendering = 1

let g:loaded_netrwPlugin = 1
nnoremap gx :call netrw#BrowseX(expand(exists('g:netrw_gx') ? g:netrw_gx : '<cfile>'), netrw#CheckIfRemote())<CR>

let g:markdown_fenced_languages = ['cucumber', 'sql']

let g:PHP_noArrowMatching = 1

" Projectionist
nnoremap <Space>a :A<CR>

let g:targets_aiAI = 'aIAi'

let g:textobj_matchit_filetype_mappings = 1

let g:vue_pre_processors = 'detect_on_enter'
