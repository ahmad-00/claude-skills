#!/usr/bin/env bash
# Install the skills in this repo into a local Claude Code skills folder.
# Default: symlink every skill into ~/.claude/skills so `git pull` updates them in place.
# Works with macOS bash 3.2 and Linux bash.
#
# Usage:
#   scripts/install.sh                 # symlink all skills into ~/.claude/skills
#   scripts/install.sh --copy          # copy instead of symlink (no live updates)
#   scripts/install.sh --project DIR   # install into DIR/.claude/skills instead
#   scripts/install.sh --only NAME     # install a single skill (repeatable)
#   scripts/install.sh --force         # replace existing folders (backs them up first)
#   scripts/install.sh --uninstall     # remove links/copies created from this repo
#   scripts/install.sh --list          # show skills in this repo and install status
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_DIR/plugins/senior-engineers/skills"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
MODE="link"; ACTION="install"; FORCE=0; ONLY=""

while [ $# -gt 0 ]; do
  case "$1" in
    --copy) MODE="copy" ;;
    --project) shift; [ $# -gt 0 ] || { echo "error: --project needs a directory" >&2; exit 2; }
               TARGET="$(cd "$1" && pwd)/.claude/skills" ;;
    --only) shift; [ $# -gt 0 ] || { echo "error: --only needs a skill name" >&2; exit 2; }
            ONLY="$ONLY $1" ;;
    --force) FORCE=1 ;;
    --uninstall) ACTION="uninstall" ;;
    --list) ACTION="list" ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "error: unknown option $1 (see --help)" >&2; exit 2 ;;
  esac
  shift
done

[ -d "$SKILLS_SRC" ] || { echo "error: skills folder not found at $SKILLS_SRC" >&2; exit 1; }

selected() {  # $1 = skill name
  [ -z "$ONLY" ] && return 0
  for n in $ONLY; do [ "$n" = "$1" ] && return 0; done
  return 1
}

is_ours() {  # $1 = path in target; true if it is a link into this repo or a copy we marked
  if [ -L "$1" ]; then
    case "$(readlink "$1")" in "$SKILLS_SRC"/*) return 0 ;; esac
    return 1
  fi
  [ -f "$1/.installed-from" ] && grep -qx "$REPO_DIR" "$1/.installed-from" 2>/dev/null
}

mkdir -p "$TARGET"
count=0
for src in "$SKILLS_SRC"/*/; do
  src="${src%/}"; name="$(basename "$src")"
  [ -f "$src/SKILL.md" ] || continue
  selected "$name" || continue
  dest="$TARGET/$name"

  case "$ACTION" in
    list)
      if is_ours "$dest"; then state="installed"; elif [ -e "$dest" ]; then state="CONFLICT (other folder)"; else state="not installed"; fi
      printf "%-28s %s\n" "$name" "$state" ;;
    uninstall)
      if is_ours "$dest"; then rm -rf "$dest"; echo "removed  $dest"; count=$((count+1))
      elif [ -e "$dest" ]; then echo "skipped  $dest (not installed from this repo)"; fi ;;
    install)
      if [ -e "$dest" ] || [ -L "$dest" ]; then
        if is_ours "$dest"; then rm -rf "$dest"
        elif [ "$FORCE" -eq 1 ]; then
          backup="$dest.bak.$(date +%Y%m%d%H%M%S)"; mv "$dest" "$backup"; echo "backup   $backup"
        else
          echo "skipped  $dest already exists and is not from this repo (use --force)"; continue
        fi
      fi
      if [ "$MODE" = "link" ]; then
        ln -s "$src" "$dest"
      else
        cp -R "$src" "$dest"; echo "$REPO_DIR" > "$dest/.installed-from"
      fi
      chmod +x "$src"/scripts/*.sh 2>/dev/null || true
      echo "$MODE    $name -> $dest"; count=$((count+1)) ;;
  esac
done

case "$ACTION" in
  install)
    echo "Done: $count skill(s) in $TARGET"
    echo "Open Claude Code and run /skills to confirm. Start a new session if they don't show up." ;;
  uninstall) echo "Done: removed $count skill(s) from $TARGET" ;;
esac
