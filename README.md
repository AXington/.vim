Vim configuration
=================

My slick + opinionated `.vimrc` configuration file.


Branches
--------

This configuration comes in three flavors:

| Branch      | Description |
|-------------|-------------|
| `vanilla`   | Self-contained `.vimrc`, no plugins. Upstream-synced. |
| `heavenly`  | vanilla + plugins via [pathogen]. Ali's modernized fork. |
| `Divine`    | heavenly + personal customizations (python-mode, whitespace display, `jj` escape). |

[pathogen]: https://github.com/tpope/vim-pathogen


Installation
------------

### Linux / Mac

    $ cd
    $ rm -rf .vim
    $ git clone https://github.com/AXington/.vim.git
    $ ln -s .vim/.vimrc

### Windows

Installing this Vim configuration under Windows is similar to Linux and Mac:
clone the repository into your Windows user profile and create a symbolic link
using the [Link Shell Extension] tool.

[Link Shell Extension]: http://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html


Key Mappings — Core
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


Customization
-------------

To adjust the configuration without touching this repo, create a `~/.vimrc.local`
file in your home directory. It is sourced automatically at the end of `.vimrc`.
