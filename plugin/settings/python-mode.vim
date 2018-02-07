" -- python-mode settings -------------------------------------------------------------

" -- general settings -------------------------------------------------------------
let g:pymode_python = 'python3'

" Use virtualenv
let g:pymode_virtualenv = 1


" -- style options -------------------------------------------------------------
let g:pymode_trim_whitespaces = 1
let g:pymode_options_max_line_length = 120
let g:pymode_indent = 1


" -- linting options -------------------------------------------------------------
let g:pymode_lint = 1
let g:pymode_lint_on_write = 1
let g:pymode_lint_checkers = ["pyflakes", "pep8", "mccabe", "pep257"]
let g:pymode_lint_options_pep8 = {'max_line_length': g:pymode_options_max_line_length}


" -- completion options -------------------------------------------------------------
let g:pymode_rope_completion = 1
let g:pymode_rope_completion_bind = '<C-Space>'


" -- refactoring options -------------------------------------------------------------
let g:pymode_rope_organize_imports_bind = '<C-c>ro'


" -- syntax highlighting -------------------------------------------------------------
let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_print_as_function = 0
let g:pymode_syntax_indent_errors = g:pymode_syntax_all

