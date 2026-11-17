#!/usr/bin/env bash

command -v dconf >/dev/null 2>&1 || exit 0

dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" ||
  echo "Could not set dark mode, skipping" >&2
