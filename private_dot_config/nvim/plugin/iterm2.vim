" Feature: Configuration to make Neovim work nice with macOS/iTerm2

" Copy to system clipboard. In iTerm, ⌘C should be mapped to send F13 (escape sequence "[1;2P").
" Unfortunately, the sequence for <D-c>, "[67;9u", isn't supported by Neovim yet. See:
" * https://github.com/neovim/neovim/issues/176#issuecomment-716012675
" * https://github.com/neovim/neovim/pull/4317
" * https://github.com/neovim/neovim/issues/2204
xnoremap <F13> "+y

" Horizontal scrolling with Shift
nnoremap <S-ScrollWheelUp> zh
nnoremap <S-2-ScrollWheelUp> 3zh
nnoremap <S-3-ScrollWheelUp> <ScrollWheelLeft>
nnoremap <S-4-ScrollWheelUp> <ScrollWheelLeft>
nnoremap <S-ScrollWheelDown> zl
nnoremap <S-2-ScrollWheelDown> 3zl
nnoremap <S-3-ScrollWheelDown> <ScrollWheelRight>
nnoremap <S-4-ScrollWheelDown> <ScrollWheelRight>
