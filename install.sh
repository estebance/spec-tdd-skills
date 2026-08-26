#!/usr/bin/env bash
#
# Sync this repo's skills and agents into a Claude Code directory.
#
#   ./install.sh              # sync into ~/.claude
#   ./install.sh --dry-run    # show what would change, touch nothing
#   ./install.sh --target .claude   # sync into a project-local .claude/
#
# This repo is the source of truth: anything it defines overwrites the copy in
# the target. Skills/agents in the target that this repo doesn't define are left
# alone.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}/.claude"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --target)  TARGET="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

changed=0

say() { printf '%s\n' "$*"; }
act() { [[ $DRY_RUN -eq 1 ]] || "$@"; }

sync_skill() {
  local src="$1" name dest
  name="$(basename "$src")"
  dest="${TARGET}/skills/${name}"

  if [[ -d "$dest" ]] && diff -rq --exclude=.DS_Store "$src" "$dest" >/dev/null 2>&1; then
    say "  = ${name} (up to date)"
    return
  fi

  if [[ -d "$dest" ]]; then
    say "  ~ ${name} (updating)"
  else
    say "  + ${name} (new)"
  fi
  changed=1

  act rm -rf "$dest"
  act mkdir -p "$dest"
  act sh -c 'cd "$1" && tar cf - --exclude .DS_Store . | (cd "$2" && tar xf -)' _ "$src" "$dest"
}

sync_agent() {
  local src="$1" name dest
  name="$(basename "$src")"
  dest="${TARGET}/agents/${name}"

  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    say "  = ${name} (up to date)"
    return
  fi

  if [[ -f "$dest" ]]; then
    say "  ~ ${name} (updating)"
  else
    say "  + ${name} (new)"
  fi
  changed=1

  act cp "$src" "$dest"
}

say "syncing ${REPO_DIR} -> ${TARGET}"
[[ $DRY_RUN -eq 1 ]] && say "(dry run — no changes will be made)"

say ""
say "skills:"
act mkdir -p "${TARGET}/skills"
found_skill=0
for skill in "${REPO_DIR}"/*/; do
  [[ -f "${skill}SKILL.md" ]] || continue
  found_skill=1
  sync_skill "${skill%/}"
done
[[ $found_skill -eq 1 ]] || say "  (none found)"

say ""
say "agents:"
if compgen -G "${REPO_DIR}/agents/*.md" >/dev/null; then
  act mkdir -p "${TARGET}/agents"
  for agent in "${REPO_DIR}"/agents/*.md; do
    sync_agent "$agent"
  done
else
  say "  (none found)"
fi

say ""
if [[ $changed -eq 0 ]]; then
  say "everything already in sync."
elif [[ $DRY_RUN -eq 1 ]]; then
  say "dry run complete — re-run without --dry-run to apply."
else
  say "done. restart Claude Code (or start a new session) to pick up changes."
fi
