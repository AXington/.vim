#!/usr/bin/env bash
#
# manage-vim-plugins.sh — Add, remove, and update Vim plugins as git submodules
#
# Usage:
#   ./manage-vim-plugins.sh <command> [options] [args]
#
# Commands:
#   update [all|<name>...]    Update one, several, or all plugins to latest (default)
#   add <url> [options]       Add a new plugin submodule
#   remove <name>...          Remove one or more plugins
#   list                      List all registered plugins
#
# Options (update):
#   --dry-run           Show what would happen without making changes
#   --no-commit         Do not commit superproject pointer updates
#   --verbose           More detailed output
#
# Options (add):
#   --name <name>       Override plugin name (default: repo basename without .git)
#   --branch <branch>   Pin to a specific branch in .gitmodules
#   --no-commit         Do not commit after adding
#
# Options (remove):
#   --keep-settings     Do not remove plugin/settings/<name>.vim if present
#   --no-commit         Do not commit after removing
#
# Global options:
#   -h, --help          Show this help and exit
#
# Examples:
#   ./manage-vim-plugins.sh update
#   ./manage-vim-plugins.sh update nerdtree fugitive
#   ./manage-vim-plugins.sh update --dry-run
#   ./manage-vim-plugins.sh add https://github.com/junegunn/vim-easy-align
#   ./manage-vim-plugins.sh add https://github.com/dense-analysis/ale --branch master
#   ./manage-vim-plugins.sh remove yankring easytags
#   ./manage-vim-plugins.sh remove ctrlp --keep-settings
#   ./manage-vim-plugins.sh list
#
# Notes:
# - Run from the root of your ~/.vim Git repository (where .gitmodules lives).
# - For first-time setup on a new machine: git submodule update --init --recursive
#

set -euo pipefail

BUNDLE_DIR="bundle"
SETTINGS_DIR="plugin/settings"

# ------------------------------
# Logging
# ------------------------------
log()  { printf '%s\n' "$*"; }
vlog() { [[ ${VERBOSE:-0} -eq 1 ]] && printf '[verbose] %s\n' "$*" || true; }
err()  { printf 'ERROR: %s\n' "$*" >&2; }

die() { err "$1"; exit "${2:-1}"; }

# ------------------------------
# Subcommand dispatch
# ------------------------------
COMMAND=""
declare -a ARGS=()

print_help() { grep '^#' "$0" | sed 's/^# \{0,1\}//'; }

if [[ $# -eq 0 ]]; then
  COMMAND="update"
  ARGS=(all)
else
  case "$1" in
    update|add|remove|list) COMMAND="$1"; shift; ARGS=("$@") ;;
    -h|--help) print_help; exit 0 ;;
    --*|-*)    COMMAND="update"; ARGS=("$@") ;;  # backward compat: bare flags = update
    *)         COMMAND="update"; ARGS=("$@") ;;  # backward compat: bare names = update targets
  esac
fi

# ------------------------------
# Shared preconditions
# ------------------------------
require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1" 127
}
require_cmd git
require_cmd awk
require_cmd sed

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "Run this script from the root of your ~/.vim Git repository."

[[ -f ".gitmodules" ]] \
  || die "No .gitmodules found. Are you in the right directory?"

# ------------------------------
# Shared helpers
# ------------------------------
all_submodule_paths() {
  git config -f .gitmodules --get-regexp '^submodule\..*\.path' | awk '{print $2}'
}

name_to_path() {
  local target="$1"
  local p base
  while IFS= read -r p; do
    base="$(basename "$p")"
    if [[ "$base" == "$target" || "$p" == "$target" ]]; then
      printf '%s' "$p"
      return 0
    fi
  done < <(all_submodule_paths)
  return 1
}

submodule_key_for_path() {
  local path="$1"
  git config -f .gitmodules --get-regexp '^submodule\..*\.path' \
    | awk -v p="$path" '$2==p { gsub(/^submodule\./,"",$1); gsub(/\.path$/,"",$1); print $1; exit }'
}

require_clean_tree() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    die "Working tree has staged or unstaged changes. Commit or stash them first."
  fi
}

# ------------------------------
# Command: list
# ------------------------------
cmd_list() {
  local count=0 p url branch
  log "Registered plugins:"
  while IFS= read -r p; do
    local key
    key="$(submodule_key_for_path "$p")"
    url="$(git config -f .gitmodules "submodule.${key}.url" || echo '?')"
    branch="$(git config -f .gitmodules "submodule.${key}.branch" 2>/dev/null || echo '')"
    if [[ -n "$branch" ]]; then
      printf '  %-28s  %-55s  [branch: %s]\n' "$(basename "$p")" "$url" "$branch"
    else
      printf '  %-28s  %s\n' "$(basename "$p")" "$url"
    fi
    (( count++ )) || true
  done < <(all_submodule_paths)
  log ""
  log "${count} plugin(s) registered."
}

# ------------------------------
# Command: add
# ------------------------------
cmd_add() {
  local PLUGIN_NAME="" PIN_BRANCH="" DO_COMMIT=1
  local url=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)      shift; PLUGIN_NAME="$1" ;;
      --branch)    shift; PIN_BRANCH="$1" ;;
      --no-commit) DO_COMMIT=0 ;;
      -h|--help)   print_help; exit 0 ;;
      -*)          die "Unknown option for add: $1" 2 ;;
      *)
        if [[ -z "$url" ]]; then url="$1"
        else die "Unexpected argument: $1. Usage: manage-vim-plugins.sh add <url> [--name <name>] [--branch <branch>]" 2
        fi ;;
    esac
    shift
  done

  [[ -n "$url" ]] || die "Usage: manage-vim-plugins.sh add <url> [--name <name>] [--branch <branch>]"

  # Derive name from URL if not provided
  if [[ -z "$PLUGIN_NAME" ]]; then
    PLUGIN_NAME="$(basename "$url" .git)"
  fi

  local path="${BUNDLE_DIR}/${PLUGIN_NAME}"

  # Check for existing registration
  if git config -f .gitmodules "submodule.${path}.url" >/dev/null 2>&1; then
    die "Plugin '${PLUGIN_NAME}' is already registered at ${path}."
  fi
  if [[ -e "$path" ]]; then
    die "Path '${path}' already exists. Remove it or choose a different --name."
  fi

  require_clean_tree

  log "Adding plugin: ${PLUGIN_NAME}"
  log "  URL:  ${url}"
  log "  Path: ${path}"
  [[ -n "$PIN_BRANCH" ]] && log "  Pinned branch: ${PIN_BRANCH}"

  git submodule add --depth 1 "$url" "$path"

  if [[ -n "$PIN_BRANCH" ]]; then
    git config -f .gitmodules "submodule.${path}.branch" "$PIN_BRANCH"
    git add .gitmodules
    log "  Pinned branch '${PIN_BRANCH}' written to .gitmodules."
  fi

  # Create a stub settings file if the settings directory exists
  local settings_file="${SETTINGS_DIR}/${PLUGIN_NAME}.vim"
  if [[ -d "$SETTINGS_DIR" && ! -f "$settings_file" ]]; then
    printf '" -- %s settings -----------------------------------------------------------\n\n' \
      "$PLUGIN_NAME" > "$settings_file"
    git add "$settings_file"
    log "  Created stub settings file: ${settings_file}"
  fi

  if [[ $DO_COMMIT -eq 1 ]]; then
    git commit -m "Add plugin: ${PLUGIN_NAME} (${url})"
    log "Committed: Add plugin ${PLUGIN_NAME}"
  else
    log "Skipping commit (--no-commit). Stage is ready — commit when ready."
  fi

  log "Done. To initialize on this machine: git submodule update --init ${path}"
}

# ------------------------------
# Command: remove
# ------------------------------
cmd_remove() {
  local KEEP_SETTINGS=0 DO_COMMIT=1
  declare -a NAMES=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --keep-settings) KEEP_SETTINGS=1 ;;
      --no-commit)     DO_COMMIT=0 ;;
      -h|--help)       print_help; exit 0 ;;
      -*)              die "Unknown option for remove: $1" 2 ;;
      *)               NAMES+=("$1") ;;
    esac
    shift
  done

  [[ ${#NAMES[@]} -gt 0 ]] \
    || die "Usage: manage-vim-plugins.sh remove <name> [<name>...] [--keep-settings] [--no-commit]"

  require_clean_tree

  declare -a REMOVED=()

  for name in "${NAMES[@]}"; do
    local path
    path="$(name_to_path "$name")" \
      || die "Plugin '${name}' not found in .gitmodules. Use 'list' to see registered plugins."

    log "------------------------------------------------------------"
    log "Removing plugin: ${name} (${path})"

    # Deinit — tolerates uninitialized submodules
    git submodule deinit -f -- "$path" 2>/dev/null || true

    # Remove from working tree and index
    git rm -f "$path" 2>/dev/null || true

    # Clean up the cached module metadata
    local modules_path=".git/modules/${path}"
    if [[ -d "$modules_path" ]]; then
      rm -rf "$modules_path"
      vlog "Removed cached module metadata: ${modules_path}"
    fi

    # Remove settings file unless --keep-settings
    local settings_file="${SETTINGS_DIR}/${name}.vim"
    if [[ -f "$settings_file" ]]; then
      if [[ $KEEP_SETTINGS -eq 1 ]]; then
        log "  Keeping settings file: ${settings_file} (--keep-settings)"
      else
        git rm -f "$settings_file"
        log "  Removed settings file: ${settings_file}"
      fi
    fi

    REMOVED+=("$name")
    log "  Done."
  done

  if [[ ${#REMOVED[@]} -gt 0 && $DO_COMMIT -eq 1 ]]; then
    if ! git diff --cached --quiet; then
      git commit -m "Remove plugin(s): ${REMOVED[*]}"
      log "============================================================"
      log "Committed removal of: ${REMOVED[*]}"
    else
      log "Nothing staged to commit after removal."
    fi
  elif [[ $DO_COMMIT -eq 0 ]]; then
    log "Skipping commit (--no-commit). Stage is ready — commit when ready."
  fi
}

# ------------------------------
# Command: update
# ------------------------------
cmd_update() {
  local DRY_RUN=0 DO_COMMIT=1 VERBOSE=0
  declare -a TARGETS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)   DRY_RUN=1 ;;
      --no-commit) DO_COMMIT=0 ;;
      --verbose)   VERBOSE=1 ;;
      -h|--help)   print_help; exit 0 ;;
      -*)          die "Unknown option for update: $1" 2 ;;
      *)           TARGETS+=("$1") ;;
    esac
    shift
  done

  [[ ${#TARGETS[@]} -eq 0 ]] && TARGETS=(all)

  if [[ $DRY_RUN -eq 0 ]]; then require_clean_tree; fi

  # Build path list from .gitmodules
  mapfile -t SUBMODULE_PATHS < <(all_submodule_paths)
  [[ ${#SUBMODULE_PATHS[@]} -gt 0 ]] || { log "No submodules registered."; exit 0; }

  # Resolve targets to paths
  declare -a SELECTED_PATHS=()
  add_path() {
    local p="$1"
    for e in "${SELECTED_PATHS[@]+"${SELECTED_PATHS[@]}"}"; do [[ "$e" == "$p" ]] && return; done
    SELECTED_PATHS+=("$p")
  }

  declare -a NOT_FOUND=()
  for t in "${TARGETS[@]}"; do
    if [[ "$t" == "all" ]]; then
      for p in "${SUBMODULE_PATHS[@]}"; do add_path "$p"; done
    else
      local resolved
      resolved="$(name_to_path "$t")" && add_path "$resolved" || NOT_FOUND+=("$t")
    fi
  done

  if [[ ${#NOT_FOUND[@]} -gt 0 ]]; then
    err "Could not resolve: ${NOT_FOUND[*]}"
    log "Use 'list' to see available plugins."
    exit 1
  fi

  # Branch resolution helpers (scoped to update)
  _branch_from_gitmodules() {
    git config -f .gitmodules "submodule.${1}.branch" 2>/dev/null || true
  }
  _remote_default_branch() {
    git -C "$1" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null \
      | sed 's#^origin/##' || true
  }
  _remote_branch_exists() {
    git -C "$1" rev-parse --verify --quiet "origin/${2}" >/dev/null 2>&1
  }
  choose_branch() {
    local key="$1" path="$2" pinned def
    pinned="$(_branch_from_gitmodules "$key")"
    if [[ -n "${pinned:-}" ]]; then printf '%s' "$pinned"; return; fi
    def="$(_remote_default_branch "$path")"
    if [[ -n "${def:-}" ]]; then printf '%s' "$def"; return; fi
    _remote_branch_exists "$path" main  && printf 'main'   && return
    _remote_branch_exists "$path" master && printf 'master' && return
  }

  declare -a UPDATED_PATHS=()
  declare -A OLD_SHA=() NEW_SHA=() TARGET_BRANCH=()

  for path in "${SELECTED_PATHS[@]}"; do
    if [[ ! -d "$path/.git" && ! -f "$path/.git" ]]; then
      err "Not initialized: ${path} — run: git submodule update --init ${path}"
      continue
    fi

    local key
    key="$(submodule_key_for_path "$path")"
    [[ -n "$key" ]] || { err "Could not resolve submodule key for ${path}"; continue; }

    log "------------------------------------------------------------"
    log "Updating: $(basename "$path") (${path})"

    local old_sha branch
    old_sha="$(git -C "$path" rev-parse --short HEAD 2>/dev/null || echo 'UNKNOWN')"
    vlog "Current HEAD: ${old_sha}"

    if [[ $DRY_RUN -eq 1 ]]; then
      log "[dry-run] Would fetch origin and fast-forward"
      OLD_SHA["$path"]="$old_sha"; NEW_SHA["$path"]="(dry-run)"
      UPDATED_PATHS+=("$path"); TARGET_BRANCH["$path"]="(dry-run)"
      continue
    fi

    git -C "$path" fetch --prune origin

    branch="$(choose_branch "$key" "$path")"
    if [[ -z "${branch:-}" ]]; then
      err "Cannot determine target branch for $(basename "$path"). Skipping."
      continue
    fi
    vlog "Target branch: ${branch}"

    # Ensure local branch tracks remote
    if ! git -C "$path" rev-parse --verify --quiet "$branch" >/dev/null 2>&1; then
      git -C "$path" checkout -B "$branch" "origin/$branch" || {
        err "Failed to checkout ${branch} for $(basename "$path"). Skipping."
        continue
      }
    else
      local cur_branch
      cur_branch="$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'HEAD')"
      [[ "$cur_branch" != "$branch" ]] && git -C "$path" checkout "$branch"
      git -C "$path" branch --set-upstream-to="origin/$branch" "$branch" 2>/dev/null || true
    fi

    if ! git -C "$path" pull --ff-only --no-rebase 2>/dev/null; then
      err "Non-fast-forward for $(basename "$path") on ${branch}. Skipping."
      continue
    fi

    local new_sha
    new_sha="$(git -C "$path" rev-parse --short HEAD)"
    OLD_SHA["$path"]="$old_sha"
    NEW_SHA["$path"]="$new_sha"
    TARGET_BRANCH["$path"]="$branch"
    UPDATED_PATHS+=("$path")

    if [[ "$old_sha" == "$new_sha" ]]; then
      log "  Already up to date."
    else
      log "  Updated: ${old_sha} -> ${new_sha} (${branch})"
    fi
  done

  # Summary
  log "============================================================"
  log "Update summary (${#UPDATED_PATHS[@]} processed):"
  for p in "${UPDATED_PATHS[@]+"${UPDATED_PATHS[@]}"}"; do
    printf '  %-38s  %s -> %s  [%s]\n' \
      "$(basename "$p")" "${OLD_SHA[$p]}" "${NEW_SHA[$p]}" "${TARGET_BRANCH[$p]}"
  done

  # Commit superproject pointer bumps
  if [[ ${#UPDATED_PATHS[@]} -gt 0 && $DRY_RUN -eq 0 && $DO_COMMIT -eq 1 ]]; then
    git add "${UPDATED_PATHS[@]}" 2>/dev/null || true
    if git diff --cached --quiet; then
      log "No superproject changes to commit (all pointers unchanged)."
    else
      local msg
      msg="Update plugins: $(date -u +'%Y-%m-%d')"
      git commit -m "$msg"
      log "Committed: ${msg}"
    fi
  elif [[ $DRY_RUN -eq 1 ]]; then
    log "[dry-run] No changes made."
  elif [[ $DO_COMMIT -eq 0 ]]; then
    log "Skipping commit (--no-commit)."
    [[ ${#UPDATED_PATHS[@]} -gt 0 ]] \
      && log "Hint: git add ${UPDATED_PATHS[*]} && git commit -m 'Update plugins'"
  fi

  log "Done."
}

# ------------------------------
# Dispatch
# ------------------------------
case "$COMMAND" in
  list)   cmd_list ;;
  add)    cmd_add    "${ARGS[@]+"${ARGS[@]}"}" ;;
  remove) cmd_remove "${ARGS[@]+"${ARGS[@]}"}" ;;
  update) cmd_update "${ARGS[@]+"${ARGS[@]}"}" ;;
  *)      die "Unknown command: ${COMMAND}. Run with --help for usage." 2 ;;
esac
