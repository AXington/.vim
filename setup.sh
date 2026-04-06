#!/usr/bin/env bash
#
# setup.sh — First-time setup for this Vim configuration (vanilla branch).
#
# Creates the ~/.vimrc symlink and checks for Vim 8+.
# Safe to run multiple times.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC_TARGET="${HOME}/.vimrc"
VIMRC_SOURCE="${SCRIPT_DIR}/.vimrc"

if [[ -t 1 ]]; then
  G='\033[0;32m' Y='\033[1;33m' R='\033[0;31m' B='\033[1m' N='\033[0m'
else
  G='' Y='' R='' B='' N=''
fi

ok()   { printf "${G}  ✓${N}  %s\n" "$*"; }
warn() { printf "${Y}  !${N}  %s\n" "$*"; }
fail() { printf "${R}  ✗${N}  %s\n" "$*" >&2; }
step() { printf "\n${B}── %s${N}\n" "$*"; }

# ------------------------------
# Prerequisites
# ------------------------------
step "Prerequisites"

if command -v vim >/dev/null 2>&1; then
  VIM_VER="$(vim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  if [[ "${VIM_VER%%.*}" -ge 8 ]]; then
    ok "Vim ${VIM_VER}"
  else
    warn "Vim ${VIM_VER} — Vim 8+ recommended"
  fi
else
  fail "vim not found"
  [[ "$(uname -s)" == "Darwin" ]] && printf "       brew install vim\n" || printf "       sudo apt install vim\n"
  exit 1
fi

# ------------------------------
# .vimrc symlink
# ------------------------------
step ".vimrc symlink"

if [[ -L "$VIMRC_TARGET" ]]; then
  existing="$(readlink "$VIMRC_TARGET")"
  if [[ "$existing" == "$VIMRC_SOURCE" ]]; then
    ok "~/.vimrc already points here"
  else
    warn "~/.vimrc points elsewhere: ${existing}"
    warn "Remove it manually and re-run to switch."
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

printf "\n${G}${B}Done.${N}\n\n"
