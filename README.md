<p align="center">
  <img
    src="https://images.unsplash.com/photo-1734024223698-4fd889ced859?q=80&w=4247&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    alt="Dotfiles banner"
    width="300"
  />
</p>
<p align="center">
  <img src="https://badgen.net/badge/dotfiles/chezmoi/green" alt="chezmoi badge" />
  <img src="https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white" alt="macOS badge" />
  <img src="https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=white" alt="Arch Linux badge" />
  <img src="https://img.shields.io/badge/Windows-0078D6" alt="Windows badge" />
</p>

# dotfiles

A cross-platform dotfiles setup managed with chezmoi and optimized for a modern terminal environment.</br>
Supports macOS, Arch Linux, and Windows (via WSL) with seamless configuration across different systems.</br>

Can be set up from a clean system with no prior installations.

## 🛠 Setup Guide
<details>
<summary>MacOS 🍎</summary>
</br>

1. Prevent system sleep during setup

```bash
caffeinate -dimsu &
```

2. Install Xcode Command Line Tools

```bash
xcode-select --install
```

3. Install and setup dotfiles with Chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DUKY8N
```

4. Stop sleep prevention process

```bash
killall caffeinate
```

</br>
</details>

<details>
<summary>Linux (Arch) 🐧</summary>
</br>

1. Install Arch Linux using `archinstall`

- Bootloader > Systemd-boot
- Kernels > linux
- Profile > Profiles: Niri(polkit), Greeter: ly
- Applications > Bluetooth: Enabled, Audio: pipwire
- Network configuration > Use Network Manager (default backend)
- Additional packages > base-devel, chezmoi, chromium, fcitx5-hangul, fcitx5-im, neovim
- Timezone > Asia/Seoul
- Automatic time sync (NTP) > Enabled

2. Setup dotfiles with Chezmoi

```bash
chezmoi init --apply DUKY8N
```

3. Enable Bluetooth AutoEnable

```ini
/etc/bluetooth/main.conf

[Policy]
AutoEnable=true
```

</br>
</details>

<details>
<summary>Windows 🪟</summary>
</br>

1. Install and setup dotfiles with Chezmoi

```
winget install twpayne.chezmoi
chezmoi init --apply DUKY8N
```

2. Enable Windows Subsystem for Linux (WSL) and **restart** your computer

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
```

3. Install Arch Linux on WSL

```powershell
wsl --install -d archlinux
```

4. Create a new user account and set password (inside Arch Linux)

```bash
# CUSTOMIZE: Change **username** to whatever you want
useradd -m -G wheel username
passwd username
```

5. Configure sudo permissions and install packages

```bash
mkdir -p /etc/sudoers.d
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
pacman -Syu sudo
```

6. Set WSL default user (back in PowerShell)

```powershell
# MATCH PREVIOUS: Use the same **username** from step 4
wsl --manage archlinux --set-default-user username
```

7. Install and setup dotfiles with Chezmoi (inside Arch Linux)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply DUKY8N
```

</br>
</details>
