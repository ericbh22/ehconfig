# Interactive shell preferences. Machine-specific additions belong in ~/.zshrc.local.
typeset -U path PATH
if ! command -v brew >/dev/null 2>&1; then
  for _eh_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$_eh_brew" ]]; then
      eval "$("$_eh_brew" shellenv)"
      break
    fi
  done
  unset _eh_brew
fi

export ZSH="$HOME/.oh-my-zsh"
plugins=(git)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Homebrew owns these plugin copies; no custom-plugin clones are needed.
_eh_prefix="${HOMEBREW_PREFIX:-}"
if [[ -n "$_eh_prefix" && -r "$_eh_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$_eh_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
for _eh_dir in "$HOME/.local/bin" "$HOME/.ghcup/bin" "$HOME/.splashkit"; do
  [[ -d "$_eh_dir" ]] && path=("$_eh_dir" $path)
done
[[ -r "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"

# Preserve Conda integration when Conda is installed separately.
for _eh_conda in /opt/anaconda3/bin/conda "$HOME/anaconda3/bin/conda" "$HOME/miniconda3/bin/conda"; do
  if [[ -x "$_eh_conda" ]]; then
    if _eh_conda_hook="$("$_eh_conda" shell.zsh hook 2>/dev/null)"; then
      eval "$_eh_conda_hook"
    fi
    break
  fi
done
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# The old eza alias is intentionally disabled, matching the current Mac.
# alias ls='eza --icons=always --group-directories-first --long --git --no-user --header --no-permissions'
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Keep syntax highlighting after other widget/plugin setup.
if [[ -n "$_eh_prefix" && -r "$_eh_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$_eh_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _eh_prefix _eh_dir _eh_conda _eh_conda_hook
