#!/usr/bin/env bash

PLAYER="chromium"
MAX=15
VOLUME_DISPLAY_SECONDS=1
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
STAMP_FILE="$CACHE_DIR/chromium-volume.ts"

truncate_title() {
  local t="$1"
  if [[ ${#t} -gt $MAX ]]; then t="${t:0:$((MAX-3))}…"; fi

  printf '%s' "$t"
}

format_text() {
  local icon="$1"
  local title="$2"
  local percent="$3"

  if [[ -n "$percent" ]]; then
    printf '%s  %s%% %s' "$icon" "$percent" "$title"
  else
    printf '%s  %s' "$icon" "$title"
  fi
}

get_chromium_stream_id() {
  wpctl status 2>/dev/null | awk '
    /Streams:/ { in_streams = 1; next }
    in_streams && $1 ~ /^[0-9]+\.$/ && $2 == "Chromium" { gsub(/\./, "", $1); print $1; exit }
    in_streams && /Video/ { exit }
  '
}

get_volume_percent() {
  local stream_id="$1"
  local volume

  volume=$(wpctl get-volume "$stream_id" 2>/dev/null | awk '{print $2}')
  if [[ -z "$volume" ]]; then return; fi

  awk -v v="$volume" 'BEGIN { printf "%.0f", v * 100 }'
}

volume_percent_if_recent() {
  [[ -f "$STAMP_FILE" ]] || return
  local now
  local stamp
  local stream_id

  now=$(date +%s)
  stamp=$(cat "$STAMP_FILE" 2>/dev/null)
  [[ -n "$stamp" && $((now - stamp)) -le $VOLUME_DISPLAY_SECONDS ]] || return

  stream_id=$(get_chromium_stream_id)
  [[ -n "$stream_id" ]] || return

  get_volume_percent "$stream_id"
}

fetch_status_title() {
  local status
  local title

  status=$(playerctl --player="$PLAYER" status 2>/dev/null || echo "")
  [[ -z "$status" ]] && return 1

  title=$(playerctl --player="$PLAYER" metadata --format '{{title}}' 2>/dev/null || echo "")
  title=$(truncate_title "$title")

  printf '%s\n%s' "$status" "$title"
}

set_chromium_volume() {
  local direction="$1"
  local stream_id

  stream_id=$(get_chromium_stream_id)
  if [[ -z "$stream_id" ]]; then exit 0; fi

  if [[ "$direction" == "up" ]]; then
    wpctl set-volume "$stream_id" 2%+ >/dev/null 2>&1
  else
    wpctl set-volume "$stream_id" 2%- >/dev/null 2>&1
  fi

  mkdir -p "$CACHE_DIR"
  date +%s > "$STAMP_FILE"
}

if [[ "$1" == "volume" ]]; then
  set_chromium_volume "$2"
  exit 0
fi

status_title=$(fetch_status_title) || exit 0
status=${status_title%%$'\n'*}
title=${status_title#*$'\n'}

icon=$([[ "$status" == "Playing" ]] && echo "" || echo "")

format_text "$icon" "$title" "$(volume_percent_if_recent)"
