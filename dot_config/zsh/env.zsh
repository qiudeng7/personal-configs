# Loaded by ~/.zprofile for login shells.
# Keep this file quiet. It may run brew, source Cargo's environment file, run
# `go env`, and source OrbStack's shell integration when those tools exist.

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

if [[ -r "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  path=("$PNPM_HOME" "$PNPM_HOME/bin" $path)
fi

if (( $+commands[go] )); then
  go_path="$(go env GOPATH 2>/dev/null)"
  [[ -n "$go_path" && -d "$go_path/bin" ]] && path+=("$go_path/bin")
  unset go_path
fi

# Obsidian's CLI path is macOS-specific and harmless when the app is absent.
[[ -d /Applications/Obsidian.app/Contents/MacOS ]] &&
  path+=(/Applications/Obsidian.app/Contents/MacOS)

typeset -U path PATH
export PATH

if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
  source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || true
fi
