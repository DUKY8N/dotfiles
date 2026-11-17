#!/usr/bin/env bash
set -euo pipefail

command -v yay >/dev/null && exit 0

sudo pacman -S --needed --noconfirm git base-devel

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT

git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
cd "$build_dir/yay"
makepkg -si --noconfirm
