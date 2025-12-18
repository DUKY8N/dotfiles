#!/bin/zsh

# vivid (themes)
export LS_COLORS="$(vivid generate catppuccin-mocha)"

# eza
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"

# nvim
export EDITOR="nvim"

# man
export MANPAGER="nvim +Man!"

# mise
eval "$(mise activate zsh)"
eval "$(mise completion zsh)"

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"
