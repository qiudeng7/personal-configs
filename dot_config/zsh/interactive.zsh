# Loaded only by interactive shells from ~/.zshrc.
# Side effects: compinit may create or update ~/.zcompdump; fnm may update
# Node-related environment variables; zsh-autosuggestions changes ZLE widgets.
# Security: secrets should live in ~/.config/zsh/local.private.zsh or be injected
# by a secret manager such as Infisical.

PROMPT='%F{117}%n%f %F{076}@%f %F{147}%2~%f $ '

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

alias compose='docker compose'
alias kube='kubectl'
alias ll='ls -laFh'
alias l='ls'
alias hosts='sudo vim /etc/hosts'
alias reload='source ~/.zshrc'
alias zshrc='vim ~/.zshrc'
alias vimrc='vim ~/.vimrc'

# This wrapper always passes --dangerously-skip-permissions, which disables
# Claude Code's normal permission prompts. Review this behavior before using it.
claude() {
  if [[ -z "$ANTHROPIC_AUTH_TOKEN" && -z "$ANTHROPIC_API_KEY" ]]; then
    print -u2 'claude: configure ANTHROPIC_AUTH_TOKEN or ANTHROPIC_API_KEY first'
    return 1
  fi

  ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-https://api.kimi.com/coding/}" \
    ANTHROPIC_MODEL="${ANTHROPIC_MODEL:-sonnet}" \
    command claude --dangerously-skip-permissions "$@"
}

if (( $+commands[fnm] )); then
  eval "$(fnm env --shell zsh)"
fi

zsh_autosuggestions="$HOME/.zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -r "$zsh_autosuggestions" ]] && source "$zsh_autosuggestions"
unset zsh_autosuggestions

# Do not export GITHUB_TOKEN here. Running `gh auth token` during every shell
# startup is slow and exposes the token to every child process.
export GITHUB_USER='qiudeng7'

# This file is intentionally outside chezmoi. Use it for per-machine settings
# and secrets supplied directly or by a secret manager such as Infisical.
[[ -r "$HOME/.config/zsh/local.private.zsh" ]] &&
  source "$HOME/.config/zsh/local.private.zsh"
