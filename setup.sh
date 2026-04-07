#!/usr/bin/env bash
#
# setup.sh — First-time and re-run setup for this Vim configuration.
#
# Safe to run multiple times. Detects available plugins and tools automatically.
# Performs safe operations (symlink, submodule init) and reports anything that
# needs manual attention without modifying the system beyond this repo.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="${HOME}/.vim"
VIMRC_TARGET="${HOME}/.vimrc"
VIMRC_SOURCE="${SCRIPT_DIR}/.vimrc"

case "$(uname -s)" in
  Darwin)   OS="mac" ;;
  CYGWIN*)  OS="cygwin" ;;
  MINGW*|MSYS*) OS="gitbash" ;;
  *)        OS="linux" ;;
esac

# ------------------------------
# Output helpers
# ------------------------------
if [[ -t 1 ]]; then
  G='\033[0;32m' Y='\033[1;33m' R='\033[0;31m' B='\033[1m' N='\033[0m'
else
  G='' Y='' R='' B='' N=''
fi

ok()   { printf "${G}  ✓${N}  %s\n"    "$*"; }
warn() { printf "${Y}  !${N}  %s\n"    "$*"; }
fail() { printf "${R}  ✗${N}  %s\n"    "$*" >&2; }
info() { printf "       %s\n"          "$*"; }
step() { printf "\n${B}── %s${N}\n"    "$*"; }

_suggest() {
  local brew_pkg="${1}" linux_pkg="${2:-$1}"
  case "$OS" in
    mac)     info "brew install ${brew_pkg}" ;;
    cygwin)  info "Install '${linux_pkg}' via the Cygwin package installer" ;;
    gitbash) info "Install '${brew_pkg}' and ensure it is on your PATH" ;;
    *)       info "sudo apt install ${linux_pkg}" ;;
  esac
}

ISSUES=0
note_issue() { ISSUES=$(( ISSUES + 1 )); }

# ------------------------------
# 1. Prerequisites
# ------------------------------
step "Prerequisites"

if command -v vim >/dev/null 2>&1; then
  VIM_VER="$(vim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  if [[ "${VIM_VER%%.*}" -ge 8 ]]; then
    ok "Vim ${VIM_VER}"
  else
    warn "Vim ${VIM_VER} — Vim 8+ recommended"; note_issue
  fi
else
  fail "vim not found"; _suggest vim vim; exit 1
fi

command -v git >/dev/null 2>&1 \
  && ok "git $(git --version | awk '{print $3}')" \
  || { fail "git not found"; exit 1; }

# ------------------------------
# 2. ~/.vim symlink (if repo is not at ~/.vim)
# ------------------------------
step "~/.vim"

if [[ "$SCRIPT_DIR" == "$VIM_DIR" ]]; then
  ok "Repo is already at ~/.vim"
elif [[ -L "$VIM_DIR" ]]; then
  existing="$(readlink "$VIM_DIR")"
  if [[ "$existing" == "$SCRIPT_DIR" ]]; then
    ok "~/.vim already points here"
  else
    warn "~/.vim points elsewhere: ${existing}"
    warn "Remove it manually and re-run to switch."; note_issue
  fi
elif [[ -d "$VIM_DIR" ]]; then
  warn "~/.vim exists as a real directory — cannot create symlink"
  warn "Back it up and remove it, then re-run."; note_issue
else
  ln -s "$SCRIPT_DIR" "$VIM_DIR"
  ok "~/.vim → ${SCRIPT_DIR}"
fi

# ------------------------------
# 3. .vimrc symlink
# ------------------------------
step ".vimrc symlink"

if [[ -L "$VIMRC_TARGET" ]]; then
  existing="$(readlink "$VIMRC_TARGET")"
  if [[ "$existing" == "$VIMRC_SOURCE" ]]; then
    ok "~/.vimrc already points here"
  else
    warn "~/.vimrc points elsewhere: ${existing}"
    warn "Remove it manually and re-run to switch."; note_issue
  fi
elif [[ -f "$VIMRC_TARGET" ]]; then
  warn "~/.vimrc is a regular file — backing up to ~/.vimrc.bak"
  mv "$VIMRC_TARGET" "${VIMRC_TARGET}.bak"
  ln -s "$VIMRC_SOURCE" "$VIMRC_TARGET"
  ok "Symlink created (old file saved as ~/.vimrc.bak)"
else
  ln -s "$VIMRC_SOURCE" "$VIMRC_TARGET"
  ok "~/.vimrc → ${VIMRC_SOURCE}"
fi

# ------------------------------
# 4. Git submodules (plugins)
# ------------------------------
step "Plugins"

cd "$SCRIPT_DIR"

if grep -q 'path = ' .gitmodules 2>/dev/null; then
  git submodule update --init --recursive
  ok "Submodules initialised"
else
  ok "No plugins on this branch"
fi

# ------------------------------
# 5. Optional tool checks
# ------------------------------
# Only run checks relevant to what is actually installed in bundle/

has_bundle() { [[ -d "${SCRIPT_DIR}/bundle/${1}" ]]; }

if has_bundle fzf || has_bundle fzf.vim; then
  step "fzf"
  if command -v fzf >/dev/null 2>&1; then
    ok "fzf $(fzf --version | awk '{print $1}')"
  else
    fail "fzf plugin present but fzf binary not in PATH — Ctrl-p will not work"
    _suggest fzf fzf; note_issue
  fi
  if command -v rg >/dev/null 2>&1; then
    ok "ripgrep $(rg --version | head -1 | awk '{print $2}')"
  else
    warn "ripgrep not found — fzf will use find (slower, no .gitignore support)"
    _suggest ripgrep ripgrep; note_issue
  fi
fi

if has_bundle tagbar; then
  step "Tagbar"
  if command -v ctags >/dev/null 2>&1; then
    ok "ctags $(ctags --version 2>&1 | head -1)"
  else
    warn "ctags not found — Tagbar (Ctrl-B) will not work"
    _suggest universal-ctags universal-ctags; note_issue
  fi
fi

if has_bundle ack; then
  step "ack"
  command -v ack >/dev/null 2>&1 && ok "ack" \
    || { warn "ack not found — :Ack searches will fail"; _suggest ack ack; note_issue; }
fi

if has_bundle ag; then
  step "ag"
  command -v ag >/dev/null 2>&1 && ok "ag (the silver searcher)" \
    || { warn "ag not found — :Ag searches will fail"
         _suggest the_silver_searcher silversearcher-ag; note_issue; }
fi

if has_bundle vimux; then
  step "vimux / tmux"
  command -v tmux >/dev/null 2>&1 && ok "tmux $(tmux -V | awk '{print $2}')" \
    || { warn "tmux not found — vimux mappings are auto-disabled but won't work"
         _suggest tmux tmux; }
fi

# ------------------------------
# 5. python-mode
# ------------------------------
if has_bundle python-mode; then
  step "python-mode"
  if command -v python3 >/dev/null 2>&1; then
    ok "python3 $(python3 --version 2>&1 | awk '{print $2}')"
  else
    fail "python3 not found — python-mode requires Python 3"
    _suggest python3 python3; note_issue
  fi
  for pkg in pyflakes pycodestyle mccabe pep257; do
    python3 -c "import ${pkg}" 2>/dev/null \
      && ok "  ${pkg}" \
      || { warn "${pkg} not installed (used by python-mode linting)"
           info "pip3 install ${pkg}"; note_issue; }
  done
fi

# ------------------------------
# 6. Copilot (optional)
# ------------------------------
if has_bundle copilot; then
  step "GitHub Copilot"
  if command -v node >/dev/null 2>&1; then
    NODE_MAJOR="$(node --version | grep -oE '[0-9]+' | head -1)"
    if [[ "$NODE_MAJOR" -ge 18 ]]; then
      ok "node $(node --version)"
    else
      warn "Node.js $(node --version) found — Copilot requires Node 18+"
      _suggest node nodejs; note_issue
    fi
  else
    fail "Node.js not found — required for Copilot"
    _suggest node nodejs; note_issue
  fi

  # Check authentication status without opening a browser
  if vim --not-a-term -e -u NONE \
       -c 'set rtp+=bundle/copilot' \
       -c 'if exists(":Copilot") | Copilot status | else | q! | endif' \
       -c 'q!' 2>&1 | grep -qi 'signed in'; then
    ok "Copilot authenticated"
  else
    warn "Copilot not authenticated — run ':Copilot setup' inside Vim to sign in"
    info "This opens a browser and asks you to enter a one-time code."
    info "After auth, completions appear automatically as you type."
    info "Accept with Ctrl-j  |  Next suggestion: Ctrl-]  |  Dismiss: Ctrl-e"
    note_issue
  fi
fi


printf "\n"
if [[ $ISSUES -eq 0 ]]; then
  printf "${G}${B}All done.${N} Open something: vim .\n\n"
else
  printf "${Y}${B}Done${N} — ${ISSUES} issue(s) to address above.\n\n"
fi
