#!/usr/bin/env bash

PLAYER="chromium"
MAX=15

status=$(playerctl --player="$PLAYER" status 2>/dev/null || echo "")
title=$(playerctl --player="$PLAYER" metadata --format '{{title}}' 2>/dev/null || echo "")

if [[ -z "$status" ]]; then
  exit 0
fi

if [[ ${#title} -gt $MAX ]]; then
  title="${title:0:$((MAX-3))}…"
fi

if [[ "$status" == "Playing" ]]; then
  echo " $title"
else
  echo " $title"
fi

