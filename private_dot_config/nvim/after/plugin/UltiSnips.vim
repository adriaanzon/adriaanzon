if !exists('g:did_plugin_ultisnips')
    finish
endif

" Prevent UltiSnips from nagging you when Python provider is missing.
" Instead, display a warning message once.
if !has('python3')
  autocmd! UltiSnips_AutoTrigger
  iunmap <Tab>

  echohl WarningMsg
  echomsg '[after/plugin/UltiSnips.vim] Python provider missing, see :checkhealth'
  echohl None
endif
