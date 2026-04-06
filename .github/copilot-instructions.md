# Copilot Instructions

## Repository Overview

This is a personal Vim configuration repository with two branches:

- **`vanilla`** — a self-contained `.vimrc` with no external dependencies
- **`heavenly`** — everything in `vanilla` plus plugins managed via [pathogen](https://github.com/tpope/vim-pathogen)

The `heavenly` branch uses git submodules for each plugin under `bundle/`.

## Architecture

- `.vimrc` — main configuration (~760 lines), self-contained on the `vanilla` branch
- `.vimrc.local` — **not committed**; used for machine-local overrides (loaded at end of `.vimrc`)
- `colors/` — custom colorschemes (currently `ir_black.vim`)
- `bundle/` — plugin submodules (heavenly branch only)
- `backup/` and `tmp/` — auto-created at runtime for backups and swap files; not tracked

On the `heavenly` branch, to disable specific plugins without removing their submodule, create `~/.pathogen_disabled` and list one plugin directory name per line.

## Key Conventions

**Section headers** follow this exact format — a comment with dashes padded to column 80:
```vim
" -- section name ---------------------------------------------------------------
```

**Vim files use `textwidth=80`** (enforced via autocmd for `filetype vim`).

**`augroup` blocks always begin with `autocmd!`** to clear previously registered autocmds before adding new ones:
```vim
augroup mygroup
  autocmd!
  autocmd BufWritePre * ...
augroup END
```

**Leader key is `,`** (both `mapleader` and `maplocalleader`).

**Inline comments are column-aligned** within a section where multiple `set` or `let` statements appear together.

**`.vimrc.local` is the extension point** — do not add machine-specific or personal overrides directly to `.vimrc`. The file in this repo is Ali's own local example.

## Installation

```bash
cd ~
rm -rf .vim
git clone https://github.com/gpakosz/.vim.git
ln -s .vim/.vimrc

# For heavenly branch:
cd .vim
git checkout heavenly
git submodule init && git submodule update
```
