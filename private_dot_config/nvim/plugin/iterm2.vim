" Feature: Configuration to make Neovim work nice with macOS/iTerm2

" Mappings using the Command modifier key. iTerm2 should be configured to
" send CSI u escape sequences pressing these key combinations.
" See: `:h tui-modifyOtherKeys`, https://www.leonerd.org.uk/hacks/fixterms/, https://github.com/neovim/neovim/pull/24357
xnoremap <D-c> "+y
nnoremap <D-c> "+y
noremap <D-s> :update<CR>
inoremap <D-s> <Esc>:update<CR>

" Horizontal scrolling with Shift
nnoremap <S-ScrollWheelUp> zh
nnoremap <S-2-ScrollWheelUp> 3zh
nnoremap <S-3-ScrollWheelUp> <ScrollWheelLeft>
nnoremap <S-4-ScrollWheelUp> <ScrollWheelLeft>
nnoremap <S-ScrollWheelDown> zl
nnoremap <S-2-ScrollWheelDown> 3zl
nnoremap <S-3-ScrollWheelDown> <ScrollWheelRight>
nnoremap <S-4-ScrollWheelDown> <ScrollWheelRight>
