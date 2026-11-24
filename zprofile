# Login-shell PATH, portable across Apple Silicon and Intel Homebrew installs.
for _eh_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x "$_eh_brew" ]]; then
    eval "$("$_eh_brew" shellenv)"
    break
  fi
done
typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.ghcup/bin" ]] && path=("$HOME/.ghcup/bin" $path)

# Optional installers used on the current Mac; absent paths are skipped.
[[ -d /Library/Frameworks/Python.framework/Versions/3.13/bin ]] && path=(/Library/Frameworks/Python.framework/Versions/3.13/bin $path)
[[ -d "$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ]] && path+=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts")
[[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/opt/node@22/bin" ]] && path=("$HOMEBREW_PREFIX/opt/node@22/bin" $path)
[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
unset _eh_brew
