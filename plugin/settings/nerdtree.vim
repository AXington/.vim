" -- NERDTree settings ---------------------------------------------------------

if has("autocmd")
  augroup nerdtree_auto
    autocmd!
    autocmd StdinReadPre * let s:std_in=1
    " open a NERDTree when vim starts up with no files specified
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in") && exists(':NERDTree') | NERDTree | endif
    " open a NERDTree when vim starts up with on opening a directory
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") && exists(':NERDTree') | exe 'NERDTree' argv()[0] | wincmd p | ene | wincmd p | endif

    " close vim if the only window left open is a NERDTree
    autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") ) | q | endif

    autocmd BufEnter * if exists('g:NERDTree') && g:NERDTree.IsOpen() | execute 'silent normal R' | endif
  augroup END
endif

function! s:NERDTreeToggleAndRefresh()
  if exists('g:NERDTree') && type(g:NERDTree) == v:t_dict && has_key(g:NERDTree, 'IsOpen') && g:NERDTree.IsOpen()
    NERDTreeClose
  else
    NERDTreeFocus
    exe 'silent normal R'
  endif
endfunction

function! s:NERDTreeFindAndRefresh()
  if !(exists('g:NERDTree') && type(g:NERDTree) == v:t_dict && has_key(g:NERDTree, 'IsOpen') && g:NERDTree.IsOpen())
    NERDTreeFind
    exe 'silent normal R'
  endif
endfunction

" toggle NERDTree with <C-N>
nnoremap <silent> <C-N> :call <SID>NERDTreeToggleAndRefresh()<CR>
" find current buffer in NERDTree with <C-F>
nnoremap <silent> <C-F> :call <SID>NERDTreeFindAndRefresh()<CR>

let NERDTreeBookmarksFile=$HOME."/.vim/.NERDTreeBookmarks"
let NERDTreeQuitOnOpen=1
let NERDTreeShowBookmarks=1
let NERDTreeShowHidden=1

set noequalalways " prevents windows size equalization after NERDTree closed
