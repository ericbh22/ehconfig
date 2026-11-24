#!/bin/bash
# Link reviewed configuration only. Install dependencies separately.
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
target_home="${HOME:?HOME must identify the current account}"
dry_run=false
usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--dry-run] [--target-home ABSOLUTE_DIRECTORY]

Back up conflicting files, then create symlinks into this checkout.
Does not install packages, clone plugins or reload apps.
--dry-run      Print operations without creating directories or files.
--target-home  Explicit alternate destination for migration or fixture testing.
EOF
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=true; shift ;;
    --target-home)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      target_home="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done
case "$target_home" in
  /*) ;;
  *) printf 'Target home must be an absolute directory.\n' >&2; exit 2 ;;
esac
if [[ "$target_home" =~ ^/+$ ]]; then
  printf 'Refusing to target the filesystem root.\n' >&2
  exit 2
fi
case "$target_home" in
  */../*|*/..|*/./*|*/.)
    printf 'Target home must not contain . or .. path components.\n' >&2; exit 2 ;;
esac
target_home="${target_home%/}"
[[ ! -e "$target_home" || -d "$target_home" ]] || { printf 'Target home is not a directory.\n' >&2; exit 2; }
if [[ -d "$target_home" ]]; then
  target_home="$(cd "$target_home" && pwd -P)"
  [[ "$target_home" != / ]] || { printf 'Refusing a target that resolves to the filesystem root.\n' >&2; exit 2; }
fi
backup_root="$target_home/.local/state/ehconfig/backups/$(date +%Y%m%d-%H%M%S)-$$"
link_file() {
  local source="$repo_dir/$1" relative="$2" destination backup
  destination="$target_home/$relative"
  [[ -f "$source" ]] || { printf 'Missing source: %s\n' "$source" >&2; exit 1; }
  if [[ -L "$destination" && "$(readlink "$destination")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$destination"
    return
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    backup="$backup_root/$relative"
    printf 'Back up: %s -> %s\n' "$destination" "$backup"
    if ! $dry_run; then
      mkdir -p "$(dirname "$backup")"
      mv "$destination" "$backup"
    fi
  fi
  printf 'Link: %s -> %s\n' "$destination" "$source"
  if ! $dry_run; then
    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
  fi
}
link_file zshrc .zshrc
link_file zprofile .zprofile
link_file gitconfig .gitconfig
link_file tmux.conf .tmux.conf
link_file starship.toml .config/starship.toml
link_file aerospace.toml .config/aerospace/aerospace.toml
link_file ghostyconfig 'Library/Application Support/com.mitchellh.ghostty/config'
printf '\nFinished%s. Keep this checkout at its current path while links use it.\n' "$($dry_run && printf ' dry run' || true)"
