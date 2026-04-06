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
