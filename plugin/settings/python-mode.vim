" -- python-mode settings -------------------------------------------------------------

" default is python3
let g:pymode_python = 'python3'

let g:pymode_trim_whitespaces = 1

let g:pymode_options_max_line_length = 120

let g:pymode_indent = 1
let g:pymode_virtualenv = 1
let g:pymode_lint = 1
let g:pymode_lint_on_write = 1
let g:pymode_lint_checkers = ['pyflakes', 'pep8', 'mccabe']
let g:pymode_lint_options_pep8 =
    \ {'max_line_length': g:pymode_options_max_line_length}
