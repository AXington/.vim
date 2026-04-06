if executable('fzf')
  nnoremap <C-p> :Files<CR>
  " Optional: use ripgrep by default for :Rg
  if executable('rg')
    let $FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  endif
endif

