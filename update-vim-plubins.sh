#!/usr/bin/env bash
#
# Update Vim plugins managed as Git submodules under ~/.vim/bundle
#
# Features:
# - Update ALL submodules or a specific one by name (e.g., 'nerdtree') or path (e.g., 'bundle/nerdtree')
# - Detects branch per submodule (pinned in .gitmodules > remote HEAD > main/master)
# - Clean fetch/pull with safety checks
# - Dry run and verbose modes
# - Summarizes updates and optionally commits pointer updates in the superproject
#
# Usage:
#   ./update-vim-plugins.sh [OPTIONS] [TARGET ...]
#
# Targets:
#   all                 Update all plugins
#   <name>              Update a single plugin by name (basename of the directory under bundle/)
#   bundle/<name>       Update a single plugin by explicit path as in .gitmodules
#   Multiple targets are supported, e.g.:  ./update-vim-plugins.sh nerdtree fugitive
#
# Options:
#   --dry-run           Show what would happen without making changes
#   --no-commit         Do not commit superproject pointer updates
#   --verbose           More detailed logging
#   --list              List known plugins (from .gitmodules) and exit
#   -h, --help          Show this help and exit
#
# Notes:
# - Run this script from the root of your ~/.vim Git repository (where .gitmodules lives).
# - For a first-time setup on a new machine: git submodule update --init --recursive
#

set -euo pipefail

# ------------------------------
# CLI parsing
# ------------------------------
DRY_RUN=0
DO_COMMIT=1
VERBOSE=0
JUST_LIST=0
declare -a TARGETS=()

print_help() {
  sed -n '1,120p' "$0"
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --no-commit) DO_COMMIT=0 ;;
    --verbose)   VERBOSE=1 ;;
    --list)      JUST_LIST=1 ;;
    -h|--help)   print_help; exit 0 ;;
    -*)
      printf 'ERROR: Unknown option: %s\n' "$arg" >&2
      exit 2
      ;;
    *)
      TARGETS+=("$arg")
      ;;
  esac
done

# Default to 'all' if no targets provided (backward-friendly)
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=(all)
fi

log()  { printf '%s\n' "$*"; }
vlog() { [[ $VERBOSE -eq 1 ]] && printf '[verbose] %s\n' "$*"; }
err()  { printf 'ERROR: %s\n' "$*" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 127; }
}
require_cmd git
require_cmd sed
require_cmd awk

# ------------------------------
# Preconditions
# ------------------------------
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  err "Please run this script from the root of your ~/.vim Git repository."
  exit 1
fi

if [[ ! -f ".gitmodules" ]]; then
  err "No .gitmodules found here. Are you in your ~/.vim repo with submodules?"
  exit 1
fi

# Ensure index is clean (so the commit shows only submodule pointer changes)
if [[ $DRY_RUN -eq 0 ]]; then
  if ! git diff --quiet || ! git diff --cached --quiet; then
    err "Your working tree has staged or unstaged changes. Please commit/stash them first."
    exit 1
  fi
fi

# ------------------------------
# Read submodules from .gitmodules
# ------------------------------
# Build ordered list of submodule paths (as declared) and a lookup of basenames.
mapfile -t SUBMODULE_PATHS < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path' \
  | awk '{print $2}')

if [[ ${#SUBMODULE_PATHS[@]} -eq 0 ]]; then
  log "No submodules found in .gitmodules."
  exit 0
fi

# Build name (basename) lookup: NAME -> PATH
declare -A NAME_TO_PATH=()
for p in "${SUBMODULE_PATHS[@]}"; do
  base="$(basename "$p")"
  NAME_TO_PATH["$base"]="$p"
done

if [[ $JUST_LIST -eq 1 ]]; then
  log "Known plugins (from .gitmodules):"
  for p in "${SUBMODULE_PATHS[@]}"; do
    printf ' - %-20s  (%s)\n' "$(basename "$p")" "$p"
  done
  exit 0
fi

# ------------------------------
# Resolve targets to submodule paths
# ------------------------------
declare -a SELECTED_PATHS=()

add_selected_path() {
  local path="$1"
  # Avoid duplicates while preserving order
  for existing in "${SELECTED_PATHS[@]}"; do
    [[ "$existing" == "$path" ]] && return 0
  done
  SELECTED_PATHS+=("$path")
}

resolve_target() {
  local t="$1"
  if [[ "$t" == "all" ]]; then
    for p in "${SUBMODULE_PATHS[@]}"; do add_selected_path "$p"; done
    return 0
  fi

  # Exact path match (e.g., bundle/nerdtree)
  for p in "${SUBMODULE_PATHS[@]}"; do
    if [[ "$t" == "$p" ]]; then
      add_selected_path "$p"
      return 0
    fi
  done

  # Basename match (e.g., nerdtree)
  if [[ -n "${NAME_TO_PATH[$t]+x}" ]]; then
    add_selected_path "${NAME_TO_PATH[$t]}"
    return 0
  fi

  # Not found
  return 1
}

# Resolve each target
declare -a NOT_FOUND=()
for t in "${TARGETS[@]}"; do
  if ! resolve_target "$t"; then
    NOT_FOUND+=("$t")
  fi
done

if [[ ${#NOT_FOUND[@]} -gt 0 ]]; then
  err "Could not resolve target(s): ${NOT_FOUND[*]}"
  log "Use '--list' to see available plugins. Example:"
  log "  ./update-vim-plugins.sh --list"
  exit 1
fi

# ------------------------------
# Helpers for updating
# ------------------------------
submodule_name_for_path() {
  local path="$1"
  git config -f .gitmodules --get-regexp '^submodule\..*\.path' \
    | awk -v p="$path" '$2 == p { gsub(/^submodule\./,"",$1); gsub(/\.path$/,"",$1); print $1; exit }'
}

branch_from_gitmodules() {
  local name="$1"
  git config -f .gitmodules "submodule.${name}.branch" || true
}

remote_default_branch() {
  local path="$1"
  git -C "$path" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null \
    | sed 's#^origin/##' || true
}

remote_branch_exists() {
  local path="$1" branch="$2"
  git -C "$path" rev-parse --verify --quiet "origin/${branch}" >/dev/null 2>&1
}

choose_target_branch() {
  local name="$1" path="$2"
  local pinned def chosen=""
  pinned="$(branch_from_gitmodules "$name" || true)"

  if [[ -n "${pinned:-}" ]]; then
    chosen="$pinned"
  else
    def="$(remote_default_branch "$path" || true)"
    if [[ -n "${def:-}" ]]; then
      chosen="$def"
    elif remote_branch_exists "$path" "main"; then
      chosen="main"
    elif remote_branch_exists "$path" "master"; then
      chosen="master"
    fi
  fi

  printf '%s' "${chosen}"
}

# For summaries
declare -a UPDATED_PATHS=()
declare -A SUMMARY_OLD_SHA=()
declare -A SUMMARY_NEW_SHA=()
declare -A SUMMARY_BRANCH=()

# ------------------------------
# Update loop (selected only)
# ------------------------------
for path in "${SELECTED_PATHS[@]}"; do
  if [[ ! -d "$path/.git" && ! -f "$path/.git" ]]; then
    err "Submodule path missing or not initialized: $path"
    err "Tip: run 'git submodule update --init --recursive' and re-run."
    continue
  fi

  name="$(submodule_name_for_path "$path")"
  if [[ -z "$name" ]]; then
    err "Could not determine submodule name for path: $path (skipping)"
    continue
  fi

  log "------------------------------------------------------------"
  log "Updating submodule: $name ($path)"

  old_sha="$(git -C "$path" rev-parse --short HEAD || echo 'UNKNOWN')"
  vlog "Current HEAD: $old_sha"

  # Fetch
  if [[ $DRY_RUN -eq 1 ]]; then
    log "[dry-run] git -C \"$path\" fetch --prune origin"
  else
    git -C "$path" fetch --prune origin
  fi

  # Branch selection
  target_branch="$(choose_target_branch "$name" "$path")"
  if [[ -n "$target_branch" ]]; then
    log "Target branch: ${target_branch}"
  else
    err "Could not determine target branch for $name ($path). Skipping."
    continue
  fi

  # Ensure local branch exists & is tracking
  if [[ $DRY_RUN -eq 1 ]]; then
    log "[dry-run] (ensure local branch '${target_branch}' tracks 'origin/${target_branch}')"
  else
    if ! git -C "$path" rev-parse --verify --quiet "${target_branch}" >/dev/null; then
      git -C "$path" checkout -B "${target_branch}" "origin/${target_branch}" || {
        err "Failed to create local branch ${target_branch} tracking origin/${target_branch} for $name"
        continue
      }
    else
      current_branch="$(git -C "$path" rev-parse --abbrev-ref HEAD || echo 'HEAD')"
      if [[ "$current_branch" != "$target_branch" ]]; then
        git -C "$path" checkout "${target_branch}"
      fi
      if ! git -C "$path" rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
        git -C "$path" branch --set-upstream-to="origin/${target_branch}" "${target_branch}" || true
      fi
    fi
  fi

  # Pull latest (FF only)
  if [[ $DRY_RUN -eq 1 ]]; then
    log "[dry-run] git -C \"$path\" pull --ff-only --no-rebase"
  else
    if ! git -C "$path" pull --ff-only --no-rebase; then
      err "Non-fast-forward or pull conflict for $name on ${target_branch}. Skipping."
      continue
    fi
  fi

  new_sha="(dry-run)"
  if [[ $DRY_RUN -eq 0 ]]; then
    new_sha="$(git -C "$path" rev-parse --short HEAD || echo 'UNKNOWN')"
  fi

  UPDATED_PATHS+=("$path")
  SUMMARY_OLD_SHA["$path"]="$old_sha"
  SUMMARY_NEW_SHA["$path"]="$new_sha"
  SUMMARY_BRANCH["$path"]="$target_branch"
done

# ------------------------------
# Summary
# ------------------------------
log "============================================================"
log "Update summary:"
if [[ ${#UPDATED_PATHS[@]} -eq 0 ]]; then
  log "No submodules updated."
else
  for p in "${UPDATED_PATHS[@]}"; do
    printf ' - %-40s  %s -> %s  (branch: %s)\n' \
      "$p" "${SUMMARY_OLD_SHA[$p]}" "${SUMMARY_NEW_SHA[$p]}" "${SUMMARY_BRANCH[$p]}"
  done
fi

# ------------------------------
# Commit superproject pointer updates (optional)
# ------------------------------
if [[ ${#UPDATED_PATHS[@]} -gt 0 && $DRY_RUN -eq 0 && $DO_COMMIT -eq 1 ]]; then
  git add "${UPDATED_PATHS[@]}" || true
  if git diff --cached --quiet; then
    log "No superproject changes to commit (pointers unchanged)."
  else
    commit_msg="Update Vim plugins (submodules): $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
    git commit -m "$commit_msg"
    log "Committed superproject updates: $commit_msg"
  fi
else
  if [[ $DRY_RUN -eq 1 ]]; then
    log "[dry-run] Skipped committing superproject updates."
  elif [[ $DO_COMMIT -eq 0 ]]; then
    log "Skipping commit (per --no-commit)."
    if [[ ${#UPDATED_PATHS[@]} -gt 0 ]]; then
      log "Hint: run 'git add ${UPDATED_PATHS[*]}' and 'git commit -m \"Update plugins\"' if desired."
    fi
  fi
fi

log "Done."
``
