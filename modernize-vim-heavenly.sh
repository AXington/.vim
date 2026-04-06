#! /usr/bin/env bash
set -euo pipefail

# --- config ---
BUNDLE_DIR="bundle"

# submodules to remove entirely
REMOVE_MODULES=(
  "yankring"
  "easytags"
  "xolox-misc"
)

# updates (existing bundles expected in heavenly):
#   - replace NERDTree origin; we'll remove old and re-add the maintained fork
UPDATE_MODULES=(
  "fugitive"             # tpope/vim-fugitive
  "airline"              # vim-airline/vim-airline
  "signify"              # mhinz/vim-signify
  "vimux"                # benmills/vimux (commonly)
  "nerdtree-git"         # xuyuanp/nerdtree-git-plugin (exact path in your tree)
)

# Replacements:
#   - ctrlp -> fzf + fzf.vim
REPLACE_CTRL_P=1

echo "==> Verifying repo"
git rev-parse --is-inside-work-tree >/dev/null || { echo "Run from ~/.vim root"; exit 1; }
[[ -f .gitmodules ]] || { echo ".gitmodules missing"; exit 1; }

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree not clean. Please stash/commit first."; exit 1
fi

echo "==> Removing deprecated plugins (as submodules + .gitmodules)"
for name in "${REMOVE_MODULES[@]}"; do
  path="${BUNDLE_DIR}/${name}"
  if [[ -d "${path}" || -f "${path}" ]]; then
    echo " - Removing ${path}"
    # fully remove a submodule, robustly:
    git submodule deinit -f -- "${path}" || true
    rm -rf ".git/modules/${path}" || true
    git rm -f "${path}" || true
    # prune .gitmodules entry if present
    if git config -f .gitmodules --get-regexp "submodule\.${path//\//\.}\.path" >/dev/null 2>&1; then
      git config -f .gitmodules --remove-section "submodule.${path//\//\.}" || true
      git add .gitmodules || true
    fi
  else
    echo " - ${path} not present, skipping"
  fi
done

echo "==> Commit removal step (if any)"
if ! git diff --cached --quiet; then
  git commit -m "Remove deprecated plugins: yankring, easytags, xolox-misc"
fi

echo "==> Replace NERDTree with maintained fork (preservim/nerdtree)"
old_nt="${BUNDLE_DIR}/nerdtree"
if [[ -d "${old_nt}" || -f "${old_nt}" ]]; then
  git submodule deinit -f -- "${old_nt}" || true
  rm -rf ".git/modules/${old_nt}" || true
  git rm -f "${old_nt}" || true
  if git config -f .gitmodules --get-regexp "submodule\.${old_nt//\//\.}\.path" >/dev/null 2>&1; then
    git config -f .gitmodules --remove-section "submodule.${old_nt//\//\.}" || true
    git add .gitmodules || true
  fi
fi

echo " - Adding preservim/nerdtree"
git submodule add --depth 1 https://github.com/preservim/nerdtree "${BUNDLE_DIR}/nerdtree"

# nerdtree-git plugin naming varies. Keep current path but ensure upstream is right.
if [[ -d "${BUNDLE_DIR}/nerdtree-git" ]]; then
  echo "==> Updating nerdtree-git plugin to latest"
  ( cd "${BUNDLE_DIR}/nerdtree-git" && git fetch --all && git checkout -q -- . && git pull --ff-only || true )
fi

echo "==> Update core plugins to latest upstream"
for name in "${UPDATE_MODULES[@]}"; do
  path="${BUNDLE_DIR}/${name}"
  if [[ -d "${path}" ]]; then
    echo " - Updating ${name}"
    ( cd "${path}" && git fetch --all && \
      # Try to use origin/HEAD default; fallback to main/master:
      (git symbolic-ref --quiet --short refs/remotes/origin/HEAD >/dev/null 2>&1 && \
        def=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##') || def=""; \
        if [[ -n "$def" ]]; then git checkout -B "$def" "origin/$def"; else
          if git rev-parse --verify origin/main >/dev/null 2>&1; then git checkout -B main origin/main;
          elif git rev-parse --verify origin/master >/dev/null 2>&1; then git checkout -B master origin/master;
          fi
        fi) && \
      git pull --ff-only --no-rebase || true )
  else
    echo " - ${name} not present; skipping"
  fi
done

if [[ "${REPLACE_CTRL_P}" -eq 1 ]]; then
  echo "==> Replacing ctrlp with fzf + fzf.vim"
  ctrlp_path="${BUNDLE_DIR}/ctrlp"
  if [[ -d "${ctrlp_path}" ]]; then
    git submodule deinit -f -- "${ctrlp_path}" || true
    rm -rf ".git/modules/${ctrlp_path}" || true
    git rm -f "${ctrlp_path}" || true
    if git config -f .gitmodules --get-regexp "submodule\.${ctrlp_path//\//\.}\.path" >/dev/null 2>&1; then
      git config -f .gitmodules --remove-section "submodule.${ctrlp_path//\//\.}" || true
      git add .gitmodules || true
    fi
  fi

  # Add fzf core (binary) + fzf.vim (wrapper). fzf.vim expects fzf present.
  if [[ ! -d "${BUNDLE_DIR}/fzf" ]]; then
    git submodule add --depth 1 https://github.com/junegunn/fzf "${BUNDLE_DIR}/fzf"
  fi
  if [[ ! -d "${BUNDLE_DIR}/fzf.vim" ]]; then
    git submodule add --depth 1 https://github.com/junegunn/fzf.vim "${BUNDLE_DIR}/fzf.vim"
  fi
fi

echo "==> Commit adds/updates"
git add .
if ! git diff --cached --quiet; then
  git commit -m "Modernize: preservim/nerdtree, update core plugins, replace ctrlp with fzf + fzf.vim; remove obsolete plugins"
fi

echo "==> Quick health checks on plugin/settings/*.vim"
echo "   (Printing hints; no automatic edits.)"
HINTS=0
if grep -Rqs "g:ctrlp_" plugin/settings; then
  echo " * Found ctrlp settings under plugin/settings. Consider replacing mappings, e.g.:"
  echo "     nnoremap <C-p> :Files<CR>   \" fzf.vim replacement"
  HINTS=1
fi
if grep -Rqs "NERDTree" plugin/settings; then
  echo " * NERDTree settings found. These should continue to work with preservim/nerdtree."
  HINTS=1
fi
if grep -Rqs "YankRing" plugin/settings; then
  echo " * YankRing settings found; plugin removed. Remove those lines or migrate to native registers."
  HINTS=1
fi
if grep -Rqs "easytags" plugin/settings; then
  echo " * EasyTags settings found; plugin removed. Consider 'universal-ctags' + :helptags or other tagging workflow."
  HINTS=1
fi
if grep -Rqs "airline#" plugin/settings; then
  echo " * Airline settings found. New airline is compatible, but double-check symbols/powerline fonts."
  HINTS=1
fi
if [[ ${HINTS} -eq 0 ]]; then
  echo " * No obvious legacy settings detected."
fi

echo "==> Installing fzf binary (optional but recommended, macOS/Homebrew example)"
if command -v brew >/dev/null 2>&1; then
  echo "   You can run:  brew install fzf ripgrep bat"
  echo "   Then (one time): $(brew --prefix)/opt/fzf/install"
fi

echo "==> Done."
``
