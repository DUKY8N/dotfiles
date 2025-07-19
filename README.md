<p align="center">
  <img
    src="https://images.unsplash.com/photo-1734024223698-4fd889ced859?q=80&w=4247&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    alt="Dotfiles banner"
    width="300"
  />
</p>
<p align="center">
  <img src="https://badgen.net/badge/dotfiles/chezmoi/green" alt="chezmoi badge" />
  <img src="https://img.shields.io/badge/OS-macOS-lightgrey?&logoColor=white" alt="macOS badge" />
  <img src="https://img.shields.io/badge/OS-Windows-blue?&logoColor=white" alt="Windows badge" />
</p>

# dotfiles

A cross-platform dotfiles setup managed with chezmoi and optimized for a modern terminal environment.</br>
Supports macOS and Windows (via WSL) with seamless configuration across different systems.</br>

Can be set up from a clean system with no prior installations.

## 🛠 Setup Guide
<details>
<summary>MacOS 🍎</summary>
</br>

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

4. Stop sleep prevention

```bash
killall caffeinate
```

</br>
</details>

<details>
<summary>Windows 🪟</summary>
</br>

1. Enable Windows Subsystem for Linux (WSL) and restart your computer

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
```

2. Install WSL and Ubuntu distribution

```powershell
wsl --install -d Ubuntu
```

3. Still under construction 🚧

</br>
</details>

<details>
<summary>Linux 🐧</summary>
</br>
Still under construction 🚧
</br>
</details>
