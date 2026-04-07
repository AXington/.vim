<div align="center">
  <img src=".github/assets/divine-transparent.png" width="260" alt="Divine — a glamorous drag queen in a black sequined gown and fur stole">
  <h1>Vim configuration</h1>
  <p><em>Slick, opinionated, and unapologetically fabulous.</em></p>
</div>


Branches
--------

This configuration comes in three flavors:

| Branch      | Description |
|-------------|-------------|
| `vanilla`   | Self-contained `.vimrc`, no plugins. |
| `heavenly`  | vanilla + plugins via [pathogen]. |
| `Divine`    | heavenly + personal additions (Copilot, python-mode, jj mapping). |

Plugin management is based on Tim Pope's [pathogen].

[pathogen]: https://github.com/tpope/vim-pathogen


Plugins
-------

### Colorschemes

| Plugin | Repository |
|--------|------------|
| alduin | [AlessandroYorba/Alduin](https://github.com/AlessandroYorba/Alduin) |
| badwolf | [sjl/badwolf](https://github.com/sjl/badwolf) |
| brogrammer | [marciomazza/vim-brogrammer-theme](https://github.com/marciomazza/vim-brogrammer-theme) |
| daylerees-colour-schemes | [daylerees/colour-schemes](https://github.com/daylerees/colour-schemes) |
| molokai | [tomasr/molokai](https://github.com/tomasr/molokai) |
| one | [rakr/vim-one](https://github.com/rakr/vim-one) |
| orbital | [fcpg/vim-orbital](https://github.com/fcpg/vim-orbital) |
| peaksea | [vim-scripts/peaksea](https://github.com/vim-scripts/peaksea) |
| pink-moon | [sts10/vim-pink-moon](https://github.com/sts10/vim-pink-moon) |
| sahara | [sanctum.geek.nz/code/sahara](https://sanctum.geek.nz/code/sahara) |
| solarized | [altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized) |
| solarized8 | [lifepillar/vim-solarized8](https://github.com/lifepillar/vim-solarized8) |
| tender | [jacoborus/tender.vim](https://github.com/jacoborus/tender.vim) |

### Enhancements

| Plugin | Repository |
|--------|------------|
| abolish | [tpope/vim-abolish](https://github.com/tpope/vim-abolish) |
| ack | [mileszs/ack.vim](https://github.com/mileszs/ack.vim) |
| airline | [vim-airline/vim-airline](https://github.com/vim-airline/vim-airline) |
| buffergator | [jeetsukumaran/vim-buffergator](https://github.com/jeetsukumaran/vim-buffergator) |
| clam | [sjl/clam.vim](https://github.com/sjl/clam.vim) |
| cursorword | [itchyny/vim-cursorword](https://github.com/itchyny/vim-cursorword) |
| easymotion | [easymotion/vim-easymotion](https://github.com/easymotion/vim-easymotion) |
| endwise | [tpope/vim-endwise](https://github.com/tpope/vim-endwise) |
| fugitive | [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) |
| fzf | [junegunn/fzf](https://github.com/junegunn/fzf) |
| fzf.vim | [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) |
| gitv | [gregsexton/gitv](https://github.com/gregsexton/gitv) |
| incsearch | [haya14busa/incsearch.vim](https://github.com/haya14busa/incsearch.vim) |
| nerdcommenter | [preservim/nerdcommenter](https://github.com/preservim/nerdcommenter) |
| nerdtree | [preservim/nerdtree](https://github.com/preservim/nerdtree) |
| nerdtree-git | [Xuyuanp/nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin) |
| pasta | [sickill/vim-pasta](https://github.com/sickill/vim-pasta) |
| polyglot | [sheerun/vim-polyglot](https://github.com/sheerun/vim-polyglot) |
| recover | [chrisbra/Recover.vim](https://github.com/chrisbra/Recover.vim) |
| repeat | [tpope/vim-repeat](https://github.com/tpope/vim-repeat) |
| signature | [kshenoy/vim-signature](https://github.com/kshenoy/vim-signature) |
| signify | [mhinz/vim-signify](https://github.com/mhinz/vim-signify) |
| sleuth | [tpope/vim-sleuth](https://github.com/tpope/vim-sleuth) |
| sneak | [justinmk/vim-sneak](https://github.com/justinmk/vim-sneak) |
| splice | [sjl/splice.vim](https://github.com/sjl/splice.vim) |
| supertab | [ervandew/supertab](https://github.com/ervandew/supertab) |
| surround | [tpope/vim-surround](https://github.com/tpope/vim-surround) |
| tabular | [godlygeek/tabular](https://github.com/godlygeek/tabular) |
| tagbar | [preservim/tagbar](https://github.com/preservim/tagbar) |
| textobj-word-column | [coderifous/textobj-word-column.vim](https://github.com/coderifous/textobj-word-column.vim) |
| undotree | [mbbill/undotree](https://github.com/mbbill/undotree) |
| unimpaired | [tpope/vim-unimpaired](https://github.com/tpope/vim-unimpaired) |
| vimux | [preservim/vimux](https://github.com/preservim/vimux) |
| zoomwin | [vim-scripts/ZoomWin](https://github.com/vim-scripts/ZoomWin) |


Installation
------------

### Linux, Mac, Cygwin, and other Unix-like environments

    $ cd
    $ rm -rf .vim
    $ git clone https://github.com/gpakosz/.vim.git
    $ ln -s .vim/.vimrc

For the `heavenly` branch, run the setup script — it initialises
submodules and checks for required tools:

    $ cd .vim
    $ git checkout heavenly
    $ bash setup.sh

Or initialise submodules manually:

    $ git submodule update --init --recursive

`setup.sh` is portable: if the repo is cloned somewhere other than `~/.vim`
it will create a `~/.vim` symlink automatically.

### Windows

Several environments work well on Windows, in rough order of recommendation:

**WSL (Windows Subsystem for Linux)** — recommended for most users on Windows
10/11. Provides a full Linux environment; follow the Linux instructions above
inside your WSL terminal.

**Git Bash** — ships with [Git for Windows](https://gitforwindows.org/) and
provides a Bash shell without a full Linux environment. The Linux instructions
above work as-is.

**Cygwin** — still actively maintained; provides a Unix-like environment on
Windows. The Linux instructions above work inside a Cygwin terminal. Use the
Cygwin package installer to add vim, git, and any optional tools.

**Native Windows** — clone the repository into your Windows user profile and
create a symbolic link using the [Link Shell Extension] tool.

[Link Shell Extension]: http://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html


Plugin Management
-----------------

`manage-vim-plugins.sh` is a shell script for managing plugins as git submodules.
Run it from the root of your `.vim` repository.

```
Usage: ./manage-vim-plugins.sh <command> [options]

Commands:
  update [all|<name>...]    Update one or all plugins to latest (default)
  add <url> [--name <n>] [--branch <b>]   Add a plugin submodule
  remove <name>... [--keep-settings]      Remove one or more plugins
  list                      Show all registered plugins with URLs and branches
```

**Options:**

| Command  | Option            | Effect |
|----------|-------------------|--------|
| `update` | `--dry-run`       | Show what would happen without making changes |
| `update` | `--no-commit`     | Update pointers but do not commit |
| `update` | `--verbose`       | More detailed output |
| `add`    | `--name <name>`   | Override plugin directory name |
| `add`    | `--branch <b>`    | Pin to a specific upstream branch |
| `add`    | `--no-commit`     | Stage changes but do not commit |
| `remove` | `--keep-settings` | Skip removal of `plugin/settings/<name>.vim` |
| `remove` | `--no-commit`     | Stage changes but do not commit |

Running without arguments is equivalent to `update all`.

`add` automatically creates a stub `plugin/settings/<name>.vim` file.



-------------------

Leader key is `,`.

### Config

| Key | Mode | Action |
|-----|------|--------|
| `,ev` | normal | Edit `.vimrc` in a vertical split |
| `,sv` | normal | Source `.vimrc` and reload plugin settings |

### File & Buffer

| Key | Mode | Action |
|-----|------|--------|
| `,w` / `,W` | normal + insert | Save buffer / save all buffers |
| `,q` | normal | Quit |
| `,t` | normal | New tab |
| `,cd` | normal | `cd` to current buffer's directory |
| `,<Tab>` | normal | Switch between last two files |
| `:w!!` | command | Sudo write |

### Display

| Key | Mode | Action |
|-----|------|--------|
| `,n` | normal | Cycle line numbers: relative → absolute → off |
| `,l` | normal | Toggle display of unprintable characters |
| `<Space>` | normal | Toggle fold |

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `j` / `k` | normal + visual | Move by display line (wrap-aware) |
| `<C-h/j/k/l>` | normal | Move between splits |
| `<Tab><Tab>` | normal | Cycle to next window |
| `<S-Left/Right/Up/Down>` | normal | Resize splits |
| `,-` | normal | Horizontal split |
| `,_` | normal | Vertical split |
| `<C-e>` / `<C-y>` | normal | Scroll 2 lines down / up |
| `gI` | normal | Jump to last change position |
| `'` ↔ `` ` `` | normal | Swapped — mark jumps use line+col by default |

### Editing

| Key | Mode | Action |
|-----|------|--------|
| `Y` | normal | Yank to end of line (like `D`, `C`) |
| `U` | normal | Redo (alias for `<C-r>`) |
| `J` | normal | Join lines (cursor-preserving) |
| `S` | normal | Split line at cursor |
| `,d` / `,c` | normal | Delete / change to black hole register |
| `,y` / `,Y` | normal | Yank to system clipboard |
| `,p` / `,P` | normal | Paste from system clipboard |
| `p` / `P` | visual | Paste without overwriting unnamed register |
| `-` / `_` | normal + visual | Move current line down / up |
| `v` ↔ `<C-V>` | normal | Swap charwise and blockwise visual modes |
| `<Tab>` / `<S-Tab>` | visual | Indent / dedent selection |
| `<` / `>` | visual | Indent / dedent and stay in visual mode |
| `jk` | insert | Exit insert mode |
| `<CR>` | normal | Insert blank line below cursor |
| `,pp` | normal | Toggle paste mode |
| `,rt` | normal | Retab buffer |
| `,s` | normal | Strip trailing whitespace |
| `,v` | normal | Select last pasted text |
| `.` | visual | Repeat last normal command on each line |

### Search & Replace

| Key | Mode | Action |
|-----|------|--------|
| `,<Space>` | normal | Clear all search highlights |
| `,hs` | normal | Highlight word under cursor as search term |
| `,h1` / `,h2` / `,h3` | normal | Highlight word under cursor in yellow / cyan / green |
| `n` / `N` | normal | Centered next / previous match (with blink) |
| `*` / `#` | visual | Search for visual selection forward / backward |
| `&` | visual | Substitute visual selection across buffer |
| `,;` | normal | Start substitute for word under cursor |


Key Mappings — Plugins
----------------------

### File Navigation (fzf)

| Key | Mode | Action |
|-----|------|--------|
| `<C-p>` | normal | `:Files` fuzzy file finder (uses ripgrep if available) |

### NERDTree

| Key | Mode | Action |
|-----|------|--------|
| `<C-N>` | normal | Toggle NERDTree (auto-refreshes on open) |
| `<C-F>` | normal | Find current buffer in NERDTree |

NERDTree auto-opens when Vim starts with no file or a directory argument, and
auto-closes when it is the only remaining window.

### Git (fugitive + gitv + signify)

| Key / Command | Mode | Action |
|---------------|------|--------|
| `:git` | command | Auto-expands to `:Git` |
| `,gs` | normal | `:Git` (interactive status) |
| `,gb` | normal | `:Git blame` |
| `,gd` | normal | `:Git diff` |
| `,gl` | normal | `:Git log` |
| `,gv` | normal | `:Gitv --all` (full commit browser) |
| `,gV` | normal + visual | `:Gitv! --all` (file-level history) |

Signify shows VCS diff signs in the gutter for git, hg, and svn.

### Tmux / Shell (vimux + clam)

| Key / Command | Mode | Action |
|---------------|------|--------|
| `,rp` | normal | Prompt for a tmux command to run |
| `,rl` | normal | Re-run last vimux command |
| `,ri` | normal | Inspect the vimux runner pane |
| `,rx` | normal | Close all other tmux panes in the window |
| `,rq` | normal | Close the vimux runner pane |
| `,rs` | normal | Interrupt the running command in the runner pane |
| `!` | normal | `:Clam <cmd>` — run shell command, output in buffer |
| `!` | visual | `:ClamVisual <cmd>` — run command with selection as input |
| `:clam` | command | Auto-expands to `:Clam` |

### Editing & Alignment (tabular + supertab + abolish)

| Key / Command | Mode | Action |
|---------------|------|--------|
| `,a=` | normal + visual | Align on `=` |
| `,a:` | normal + visual | Align on `:` (after the colon) |
| `\|` | insert | Auto-align pipe-delimited table |
| `<C-Space>` / `<C-@>` | insert | SuperTab forward completion (GUI / terminal) |
| `<S-C-Space>` / `<S-C-@>` | insert | SuperTab backward completion |
| `:subvert` | command | Auto-expands to `:Subvert` (smart case-aware substitution) |

SuperTab uses context-aware completion with `<C-P>` as fallback.

### Search (incsearch + ack)

| Key / Command | Mode | Action |
|---------------|------|--------|
| `/` | normal | Incremental search forward (incsearch) |
| `?` | normal | Incremental search backward |
| `g/` | normal | incsearch stay mode — highlight without moving cursor |
| `n` / `N` / `*` / `#` / `g*` / `g#` | normal | incsearch variants with auto-nohighlight |
| `:ack` | command | Auto-expands to `:Ack` |

### Code Navigation (tagbar + undotree + buffergator + zoomwin)

| Key | Mode | Action |
|-----|------|--------|
| `<C-B>` | normal | Toggle Tagbar (symbol/tag browser) |
| `<C-u>` | normal | Toggle Undotree (opens on right, 80 cols wide) |
| `,b` | normal | Toggle Buffergator (buffer list) |
| `,+` | normal | Zoom / unzoom current window (ZoomWin) |


Divine Customizations
---------------------

The `Divine` branch extends `heavenly` with Ali's personal additions.

### Additional Plugins

| Plugin | Repository |
|--------|------------|
| copilot | [github/copilot.vim](https://github.com/github/copilot.vim) |
| python-mode | [python-mode/python-mode](https://github.com/python-mode/python-mode) |

### python-mode

Python 3 mode with virtualenv support enabled. Linting runs on write using
pyflakes, pep8, mccabe, and pep257 (max line length: 120).

| Key | Mode | Action |
|-----|------|--------|
| `<C-Space>` | insert (Python) | SuperTab routes to Rope completion in Python files |
| `<C-c>ro` | normal (Python) | Rope organize imports |

### Copilot

Inline AI completions. Requires Node.js 18+ and a GitHub Copilot subscription.
Run `:Copilot setup` on first use to authenticate (opens a browser, one-time).

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl-j` | insert | Accept suggestion |
| `Ctrl-]` | insert | Next suggestion |
| `Ctrl-e` | insert | Dismiss suggestion |

Tab is left free for SuperTab. To disable completions temporarily:
`:Copilot disable` / `:Copilot enable`.

### Personal Mappings

| Key | Mode | Action |
|-----|------|--------|
| `jj` | insert | Exit insert mode (alternative to `jk`) |

### Per-filetype Indentation

Tabs are always expanded to spaces. The number of spaces follows each
language's community convention:

| Language(s) | Spaces |
|-------------|--------|
| Python, Rust, Java, C/C++, Shell, Dockerfile | 4 |
| YAML, JSON, Terraform/HCL, JavaScript, TypeScript, HTML, CSS, Ruby, Vim, Markdown | 2 |
| Go, Makefile | tabs (required by language/tooling) |


### Whitespace Display

Tabs are shown as `>-`, trailing spaces as `~`, and line overflow markers are
active by default.



To adjust the configuration without touching this repo, create a `~/.vimrc.local`
file in your home directory. It is sourced automatically at the end of `.vimrc`.

To disable specific plugins, create a `~/.pathogen_disabled` file and list the
plugins to disable, one per line (each name matching the corresponding
`bundle/<name>` directory).
