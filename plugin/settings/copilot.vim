" -- copilot settings -----------------------------------------------------------
"
" Requires Node.js >= 18. Run :Copilot setup on first use to authenticate.
" To disable completions temporarily: :Copilot disable / :Copilot enable
" To disable for a specific filetype, add it to g:copilot_filetypes below.

" Don't show the default Tab mapping warning — we remap below
let g:copilot_no_tab_map = v:true

" Enable for all filetypes except those where it gets in the way
let g:copilot_filetypes = {
      \ 'gitcommit': v:true,
      \ 'markdown':  v:true,
      \ 'yaml':      v:true,
      \ 'TelescopePrompt': v:false,
      \ }

" Accept suggestion with Ctrl-j (keeps Tab free for SuperTab)
imap <silent><script><expr> <C-j> copilot#Accept('')

" Cycle through suggestions
imap <silent> <C-]> <Plug>(copilot-next)
imap <silent> <C-[> <Plug>(copilot-previous)

" Dismiss suggestion
imap <silent> <C-e> <Plug>(copilot-dismiss)
