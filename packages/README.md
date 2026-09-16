# Package and service lists

What was installed, so a machine can be rebuilt. Configs live in the stow packages;
this folder is only the "what to install" half. Two machines are covered.

**Arch + Sway (ThinkPad T480)**

| File | What it holds |
|------|---------------|
| `pacman-repo.txt` | packages from the official repos, installed on purpose (159) |
| `pacman-aur.txt` | packages from the AUR (11) |
| `services-system.txt` | enabled system services |
| `services-user.txt` | enabled user services |

Only packages installed **on purpose** are listed. Dependencies are left out — pacman
pulls those in by itself.

**Ubuntu on WSL2**

| File | What it holds |
|------|---------------|
| `apt-manual.txt` | every package marked manual (42) |

apt has no clean way to drop base packages from that list, so it keeps a few like
`coreutils`. Reinstalling them is a no-op. The rest of the WSL rebuild — nvm, rustup,
Docker, oh-my-zsh — is in [WSL-SETUP.md](../WSL-SETUP.md).

```bash
xargs -a packages/apt-manual.txt sudo apt install -y
```

## Rebuild

**1. Repo packages**

```bash
sudo pacman -S --needed - < packages/pacman-repo.txt
```

**2. yay first, then the AUR packages**

`yay-bin` is in the AUR list, so it cannot install itself. Build it by hand once:

```bash
git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
yay -S --needed - < packages/pacman-aur.txt
```

**3. Services**

```bash
sudo systemctl enable --now <name>   # from services-system.txt
systemctl --user enable --now <name> # from services-user.txt
```

Skip the ones Arch already enables: `getty@`, `remote-fs.target`, `systemd-timesyncd`,
`systemd-userdbd.socket`, and the `pipewire`/`wireplumber` sockets.

**4. Dotfiles**

```bash
./install.sh
```

## Notes on a few of these

- **Fingerprint reader** — needs `open-fprintd`, `python-validity`, `fprintd-clients-git`
  together, plus the `python3-validity` and `python3-validity-suspend-hotfix` services.
  The hotfix service is what keeps the reader working after suspend.
- **kanata** — `kanata.service` runs the keyboard remap. Config is in the `kanata` stow
  package. Needs the user to be in the `input` group and a `uinput` rule.
- **gdm** — the login screen. Sway and GNOME are both picked from there.
- **tlp** and **thermald** — battery life and thermal limits. Worth having on a laptop.

## Regenerate

Run on the machine itself, then commit.

Arch:

```bash
pacman -Qqen > packages/pacman-repo.txt
pacman -Qqem > packages/pacman-aur.txt
systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort > packages/services-system.txt
systemctl --user list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort > packages/services-user.txt
```

Ubuntu:

```bash
apt-mark showmanual | sort > packages/apt-manual.txt
```
