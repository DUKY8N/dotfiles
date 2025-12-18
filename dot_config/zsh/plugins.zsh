#!/bin/zsh

typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_TIMEOUT=0

_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"

source "$_PLUGIN_DIR/fzf-tab/fzf-tab.plugin.zsh"
source "$_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"

unset _PLUGIN_DIR

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
