# dotfiles

## Init

1. Prevent system sleep during setup

```bash
caffeinate -dimsu &
```

2. Install command line tools

```bash
xcode-select --install
```

3. Install chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DUKY8N
```
Prevent system sleep during setup
4. Stop sleep prevention

```bash
killall caffeinate
```
