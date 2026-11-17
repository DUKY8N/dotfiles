#!/usr/bin/env bash
set -euo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)"

# Swift toolchains
if [[ ! -r "$HOME/.swiftly/env.sh" ]]; then
  swiftly init --assume-yes --no-modify-profile --verbose
fi
