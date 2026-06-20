#!/usr/bin/env bash
set -u

# fzf-based tmux session manager.
# Intended to run inside a tmux popup, but also works from a normal shell.

command -v fzf >/dev/null || {
  echo "fzf is required" >&2
  exit 1
}

list_sessions() {
  tmux list-sessions -F "#{session_name}" 2>/dev/null || true
}

confirm() {
  local answer
  printf '%s [y/N] ' "$1" > /dev/tty
  IFS= read -r answer < /dev/tty
  [[ "$answer" =~ ^([yY]|yes|YES)$ ]]
}

pause() {
  printf 'Press Enter to continue...' > /dev/tty
  IFS= read -r _ < /dev/tty
}

session_exists() {
  tmux has-session -t="$1" 2>/dev/null
}

goto_session() {
  local target=${1:-}
  [[ -n "$target" ]] || exit 0

  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$target"
  else
    tmux attach-session -t "$target"
  fi
}

new_session() {
  local name
  printf 'New session: ' > /dev/tty
  IFS= read -r name < /dev/tty
  [[ -n "$name" ]] || exit 0

  if session_exists "$name"; then
    printf 'Session already exists: %s\n' "$name" > /dev/tty
    pause
    exit 1
  fi

  tmux new-session -d -s "$name" -c "$HOME"
  goto_session "$name"
}

rename_session() {
  local old=${1:-} new
  [[ -n "$old" ]] || exit 0

  printf 'Rename %s to: ' "$old" > /dev/tty
  IFS= read -r new < /dev/tty
  [[ -n "$new" && "$new" != "$old" ]] || exit 0

  if session_exists "$new"; then
    printf 'Session already exists: %s\n' "$new" > /dev/tty
    pause
    exit 1
  fi

  tmux rename-session -t "$old" "$new"
}

delete_session() {
  local target=${1:-} current replacement
  [[ -n "$target" ]] || exit 0

  current=$(tmux display-message -p '#S' 2>/dev/null || true)

  if [[ "$target" != "$current" ]]; then
    confirm "Delete session \"$target\"?" && tmux kill-session -t "$target"
    exit 0
  fi

  replacement=$(list_sessions | awk -v target="$target" '$0 != target { print; exit }')

  if [[ -n "$replacement" ]]; then
    if confirm "Delete current session \"$target\" and switch to \"$replacement\"?"; then
      tmux switch-client -t "$replacement"
      tmux kill-session -t "$target"
    fi
  else
    confirm "Delete last session \"$target\" and exit tmux?" && tmux kill-session -t "$target"
  fi
}

case "${1:-}" in
  --list) list_sessions; exit 0 ;;
  --switch) shift; goto_session "${1:-}"; exit 0 ;;
  --new) new_session; exit 0 ;;
  --rename) shift; rename_session "${1:-}"; exit 0 ;;
  --delete) shift; delete_session "${1:-}"; exit 0 ;;
esac

self=$0
sessions=$(list_sessions)

if [[ -z "$sessions" ]]; then
  printf 'No tmux sessions. Press Ctrl-n to create one.\n' > /dev/tty
fi

printf '%s\n' "$sessions" | fzf \
  --height=100% \
  --border=none \
  --margin=0 \
  --prompt="  " \
  --header "Open: ↵ | New: C-n | Rename: C-r | Delete: C-d" \
  --bind "enter:execute('$self' --switch {})+abort" \
  --bind "ctrl-n:execute('$self' --new)+abort" \
  --bind "ctrl-r:execute('$self' --rename {})+reload('$self' --list)" \
  --bind "ctrl-d:execute('$self' --delete {})+reload('$self' --list)"
