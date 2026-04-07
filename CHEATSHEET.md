# Cheat Sheet

Practical reference for customizations, changed defaults, and plugin workflows.
For the full key map index see [README.md](README.md). Leader key is `,`.

---

## Defaults that work differently here

These are vanilla Vim behaviors that this config changes. If something isn't
doing what you expect, it's likely one of these.

**`v` starts visual block, `Ctrl-V` starts charwise visual** — swapped from
stock Vim. Block selection is the more common need in this config, so it gets
the easier key.

**`'` and `` ` `` are swapped** — jumping to a mark with `'<letter>` lands on
the exact line *and column* (normally the backtick job). The single-quote jump
is more precise here by default.

**`j` and `k` move by display line** — on a soft-wrapped paragraph, `j` goes
to the next visible row, not the next newline. This is almost always what you
want, and arrow keys behave the same way.

**`p` and `P` in visual mode don't clobber the register** — you can paste the
same yanked text into multiple places by selecting each target and pressing `p`
without re-yanking.

**`.` in visual mode repeats on every selected line** — select several lines,
then `.` applies the last normal-mode operation to each one individually.

**`<` and `>` keep the visual selection active** — you can re-indent
immediately by pressing the key again without re-selecting.

**`U` is redo** — same as `Ctrl-r`, just easier to reach. Line-undo (the
original `U`) is gone.

**`Y` yanks to end of line** — consistent with `D` and `C`. The default `Y`
(which yanked the whole line, same as `yy`) is replaced.

**`jk` exits insert mode** — hit `j` then `k` quickly to return to normal mode.
Works everywhere insert mode is active. No need to reach for Escape.

---

## Useful custom shortcuts

**System clipboard** — `,y`/`,Y` yank to the clipboard, `,p`/`,P` paste from
it. Useful whenever you're moving text between Vim and another application.

**Black-hole delete and change** — `,d` and `,c` delete or change without
touching the unnamed register, so your last yank stays intact. Use this instead
of `d` when you're about to paste something and don't want to lose it.

**Move lines** — `-` moves the current line (or visual selection) down, `_`
moves it up. Works in normal and visual mode.

**Highlight and search the word under the cursor without moving** — `,hs`
highlights the current word as a search term but keeps the cursor where it is.
`,h1`, `,h2`, `,h3` highlight in yellow, cyan, and green respectively — useful
for colour-coding multiple things you're tracking. `,<Space>` clears all
highlights.

**Search-and-replace on the current word** — `,;` starts a `:%s/word//` with
the word under the cursor pre-filled, cursor between the slashes. Type the
replacement and press Enter.

**Sudo write** — `:w!!` rewrites the current file via sudo when you opened it
without the right permissions.

**Swap to the previous buffer** — `,<Tab>` jumps back to the last file you had
open, like `Alt-Tab` for Vim buffers.

---

## Plugins

### Finding files — fzf

`Ctrl-p` opens the fuzzy file picker. Type any fragment of the filename or
path. With ripgrep installed the listing is fast, respects `.gitignore`, and
includes hidden files (excluding `.git/`).

Inside the picker, `Ctrl-t` opens in a new tab, `Ctrl-v` opens a vertical
split, `Ctrl-x` opens a horizontal split.

### Searching the codebase — ack

`:ack <pattern>` searches the project and populates the quickfix list.
`:cn`/`:cp` step through results. To search for the exact word under the cursor,
`:Ack <C-r><C-w>` inserts it at the command line for you. Patterns are
Perl-compatible regex. ack respects `.gitignore` and ignores `.git/`.

If [ripgrep](https://github.com/BurntSushi/ripgrep) or
[ag](https://github.com/ggreer/the_silver_searcher) is installed, ack.vim will
use it automatically as a faster backend.

### Project tree — NERDTree

`Ctrl-N` opens the tree. `Ctrl-F` finds the current buffer in it — useful after
jumping to a file from search and wanting to see where it lives. The tree
refreshes automatically on open.

Inside the tree: `s` opens a file in a vertical split, `i` in a horizontal
split, `t` in a new tab, `I` toggles hidden files. NERDTree closes itself when
it's the last window.

### Search — incsearch

This plugin silently takes over `/`, `?`, `n`, `N`, `*`, `#`, `g*`, and `g#`.
The visible change: search highlights clear automatically when you do anything
other than repeat the search. You no longer need `,<Space>` after navigating to
a match — the highlighting disappears by itself.

`g/` is added: it highlights matches without moving the cursor, useful for a
quick visual count.

### Git — fugitive, gitv, and signify

Signify puts `+`/`-`/`~` change markers in the gutter continuously as you edit.
No action needed. `]c` / `[c` jump between changed hunks.

`,gs` opens the status window. Navigate to a file and:
- `-` stages or unstages it
- `=` shows its inline diff
- `dv` opens a side-by-side diff for the file

`,gd` opens a two-pane diff of the current file against the index. `]c`/`[c`
jump between hunks, `dp` pushes a hunk to the other side.

`,gv` opens the full commit graph (all branches). `,gV` (or visual `,gV`)
narrows it to the current file or selected lines — useful for `git log -L`-style
archaeology without leaving Vim.

### Running commands in tmux — vimux

`,rp` prompts for a command and runs it in a tmux pane next to your Vim
session. `,rl` repeats the last command — the main loop when iterating on
tests or a build. `,ri` focuses the pane so you can scroll through output.
`,rs` sends an interrupt to whatever is running.

Requires an active tmux session. Vim detects the absence of tmux and disables
the mappings automatically.

### Inline shell output — clam

`!` (normal mode) runs a shell command and puts its output in a scratch buffer
you can read and yank from without affecting the current file.

In visual mode, `!` pipes the selected text to the command and replaces the
selection with the output — a fast way to sort, transform, or format a block
without leaving the editor.

### Aligning text — tabular

`,a=` aligns on `=`, `,a:` aligns on `:` (colon stays with the left side).
Both work on a visual selection or the current paragraph.

Inside a `|`-delimited structure (Markdown table, Vim help file), typing `|`
triggers auto-alignment — columns stay tidy as you type.

For anything else: `:Tabularize /<pattern>` aligns on any regex. `:Tabularize
/=>` for Ruby rockets, `:Tabularize /\s\+` for space-separated columns, and so
on.

### Browsing undo history — undotree

`Ctrl-u` opens the undo tree. Vim's undo is a tree, not a linear stack — if
you undo several steps and make a new edit, the earlier branch is not lost.
The tree visualises every branch and lets you navigate to any past state of the
buffer. `q` closes it.

### Symbol browser — tagbar

`Ctrl-B` opens a symbol list for the current file (functions, classes, methods,
variables) sorted by scope. Requires ctags. Press Enter to jump to a symbol.

---

## Divine branch

### GitHub Copilot

Inline AI completions that appear as you type. Suggestions are shown in muted
text ahead of your cursor — press `Ctrl-j` to accept the whole suggestion, or
keep typing to ignore it and let the next one appear.

Tab is intentionally left free for SuperTab. The key bindings:

- `Ctrl-j` — accept the current suggestion
- `Ctrl-]` — next alternative suggestion
- `Ctrl-e` — dismiss without accepting

First-time setup: run `:Copilot setup` inside Vim. It will give you a short
code and open a browser where you paste it into GitHub. One-time per machine.
After that, completions are always on. Use `:Copilot disable` to turn them off
for a session, or add a filetype to `g:copilot_filetypes` in
`plugin/settings/copilot.vim` to disable permanently for that type.

### Python development — python-mode

The linter runs automatically on every save. Errors and warnings appear inline
in the gutter and in the quickfix list. Checkers: pyflakes, pep8, pep257,
mccabe. Max line length is 120 characters.

SuperTab (`Ctrl-Space`) drives completion and uses context-awareness to route
to Rope when in a Python file — it understands imports, class attributes, and
function signatures across the project, not just the current file's tokens.

`Ctrl-c ro` organises imports: removes unused ones, deduplicates, and sorts.

For rename, extract function, extract variable, and other refactoring
operations, use `:PymodeRope<Tab>` to see available commands.

python-mode detects your active virtualenv via `$VIRTUAL_ENV`. Activate it in
the shell before opening Vim.

### `jj` to escape insert mode

In addition to `jk`, `jj` also exits insert mode. Both land you in normal mode
at the same cursor position (last insert start point); use whichever your hands find first.

### Whitespace display

Tabs appear as `>-`, trailing spaces as `~`, and long-line overflow is marked
at the right edge — always on. `,l` toggles the display if it's in the way.

### Indentation

Tabs are always expanded to spaces. The indent width is set automatically
based on the file type you're editing — you don't need to think about it.
Open a Python file and you get 4-space indents; open a YAML file and you get
2-space indents; open a Go file and real tabs are used (because `gofmt`
requires them). The full table is in the README.

If you're working on a project that uses different conventions, you can
override locally with `:setlocal shiftwidth=4` for the current buffer, or
add a project-level `.editorconfig` file — Vim will respect it if the
`editorconfig` plugin is installed.
