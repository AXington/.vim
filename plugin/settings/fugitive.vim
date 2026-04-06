" -- fugitive settings ---------------------------------------------------------

cabbrev <expr> git (getcmdtype() == ':' && getcmdpos() <= 4) ? 'Git' : 'git'

nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gb :Git blame<CR>
nnoremap <silent> <leader>gd :Git diff<CR>
nnoremap <silent> <leader>gl :Git log<CR>

if has("statusline")
  let &statusline=substitute(&statusline, '\(%{StatusLineCWD()}\)', '\1%#SpecialChar#%{fugitive#statusline()}%*', '')
endif
