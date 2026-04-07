" -- per-filetype indentation ---------------------------------------------------
"
" Global defaults (set in .vimrc): expandtab, tabstop=2, shiftwidth=2
" This file overrides those defaults for filetypes with different conventions.
"
" sw  = shiftwidth  (indent size for << >> and autoindent)
" ts  = tabstop     (how wide a real tab character displays)
" sts = softtabstop (columns consumed when pressing Tab in insert mode)
" et  = expandtab   (insert spaces instead of tab characters)

augroup filetype_indentation
  autocmd!

  " 4-space indentation ---------------------------------------------------------

  " Python: PEP 8
  autocmd FileType python         setlocal sw=4 ts=4 sts=4 et

  " Rust: official style guide
  autocmd FileType rust           setlocal sw=4 ts=4 sts=4 et

  " Java
  autocmd FileType java           setlocal sw=4 ts=4 sts=4 et

  " C / C++
  autocmd FileType c,cpp          setlocal sw=4 ts=4 sts=4 et

  " Shell scripts
  autocmd FileType sh,bash,zsh    setlocal sw=4 ts=4 sts=4 et

  " Dockerfile
  autocmd FileType dockerfile     setlocal sw=4 ts=4 sts=4 et

  " 2-space indentation ---------------------------------------------------------
  " (matches the global default, but listed explicitly for clarity)

  " YAML (includes Ansible, Kubernetes manifests, GitHub Actions, etc.)
  autocmd FileType yaml           setlocal sw=2 ts=2 sts=2 et

  " Terraform / HCL (HashiCorp style guide)
  autocmd FileType terraform,hcl  setlocal sw=2 ts=2 sts=2 et

  " JSON
  autocmd FileType json           setlocal sw=2 ts=2 sts=2 et

  " JavaScript / TypeScript
  autocmd FileType javascript,typescript,javascriptreact,typescriptreact
        \                         setlocal sw=2 ts=2 sts=2 et

  " HTML / CSS / SCSS / templates
  autocmd FileType html,css,scss,eruby,jinja
        \                         setlocal sw=2 ts=2 sts=2 et

  " Ruby
  autocmd FileType ruby           setlocal sw=2 ts=2 sts=2 et

  " Vim script
  autocmd FileType vim            setlocal sw=2 ts=2 sts=2 et

  " Markdown
  autocmd FileType markdown       setlocal sw=2 ts=2 sts=2 et

  " Tab-based indentation -------------------------------------------------------
  " (these languages use real tab characters by convention or requirement)

  " Go: gofmt enforces tabs
  autocmd FileType go             setlocal noet ts=4 sw=4

  " Makefile: tabs are syntactically required
  autocmd FileType make           setlocal noet ts=4 sw=4

augroup END
