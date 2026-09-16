# WSL setup — the Linux half

The Windows side is in [WINDOWS-SETUP.md](WINDOWS-SETUP.md). This file covers what
runs *inside* WSL: Ubuntu, the shell, Neovim, Docker, and the files that hold
credentials and so are kept out of this repo.

Read this before rebuilding on a new laptop. The rebuild itself is short. The
part that costs time is the list under "Not in this repo" — those files exist
nowhere else.

## Ground truth

| Piece | Value |
|-------|-------|
| Distro | Ubuntu 26.04 LTS on WSL2 |
| Init | systemd, turned on in `/etc/wsl.conf` |
| Login shell | `/usr/bin/zsh`, oh-my-zsh + starship |
| Node | v22 through nvm, not apt |
| Rust | rustup, stable toolchain |
| Docker | `docker.io` inside WSL, not Docker Desktop |
| Networking | mirrored, set on the Windows side in `.wslconfig` |
| Disk | ~23 G used, of which ~11 G is `node_modules` and caches |

`/etc/wsl.conf` is four lines and is not stowed, because it lives outside home:

```ini
[boot]
systemd=true

[user]
default=alex
```

The `default=alex` line matters. Without it `wsl --import` drops you in as root.

## Not in this repo

These hold credentials, so they are deliberately outside the repo. Nothing
restores them for you. Copy them by hand, or accept losing them.

| File | What it is |
|------|------------|
| `~/.local/share/nvim/db_connections.lua` | `vim.g.dbs` for dadbod-ui. Loaded by `nvim/init.lua` |
| `~/.ssh/id_ed25519` | git auth |
| `~/code/**/.env*` | ~37 files, all gitignored |
| `~/.secrets.zsh` | optional, sourced by `.zshrc` if present |

`nvim/init.lua` loads the db file with `pcall`, so Neovim starts fine when it is
missing. The symptom is an empty DBUI sidebar and no error. Format:

```lua
vim.g.dbs = {
  { name = "shoty", url = "postgresql://USER:PASSWORD@localhost:5432/shoty" },
}
```

Repos with no git remote are in the same boat — the disk is their only copy.
Find them before any move:

```bash
cd ~/code
for d in $(find . -maxdepth 4 -name .git -type d -prune | sed 's|/.git$||'); do
  [ -z "$(git -C "$d" remote)" ] && echo "NO REMOTE  $d"
done
```

## Rebuild, in order

**1. Ubuntu and the base config**

Install Ubuntu from the Microsoft Store, then write `/etc/wsl.conf` (above) and
`wsl --shutdown` so it is read.

**2. Packages**

```bash
sudo apt update
xargs -a packages/apt-manual.txt sudo apt install -y
```

The list is every package marked manual, so it includes base ones like
`coreutils`. Reinstalling those is a no-op. Two names differ from the binary:
`fd-find` gives you `fdfind`, and `ripgrep` gives you `rg`.

**3. Dotfiles**

```bash
sudo apt install stow
git clone git@github.com:Kamesas/dotfiles_ubuntu.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Then `chsh -s /usr/bin/zsh`.

**4. Things apt does not carry**

| What | How |
|------|-----|
| oh-my-zsh | its own install script |
| zsh-autosuggestions, zsh-syntax-highlighting | `git clone` into `~/.oh-my-zsh/custom/plugins/` |
| nvm, then Node 22 | nvm install script, then `nvm install 22` |
| rustup | rustup install script |
| yazi | built or downloaded into `~/.local/bin` |
| tmux plugins | tpm, then `prefix + I` |

Neovim plugins need nothing — LazyVim installs them on first start from
`nvim/lazy-lock.json`.

**5. Docker**

```bash
sudo usermod -aG docker $USER   # log out and back in
```

The dev database container:

```bash
docker run -d --name dev-postgres --restart unless-stopped \
  -e POSTGRES_USER=alex -e POSTGRES_PASSWORD=<same as in the .env files> \
  -e POSTGRES_DB=shoty \
  -p 5432:5432 -v dev-postgres-data:/var/lib/postgresql postgres:18
```

The password has to match what the project `.env` files expect. Read it from a
running container with `docker inspect dev-postgres` before rebuilding.

Restore data from a dump, then rerun each project's migrations if needed:

```bash
docker exec -i dev-postgres psql -U alex -d shoty < shoty.sql
```

**6. Check it worked**

```bash
psql -h localhost -U alex -d shoty -c '\dt'   # needs postgresql-client
nvim                                          # then <leader>db
```

`<leader>db` opens DBUI. An empty sidebar means step "Not in this repo" was
skipped.

## Moving to another laptop

Two routes. Neither is hard.

**Full clone — `wsl --export` / `wsl --import`.** About 1 to 1.5 hours, nearly
all of it waiting on a file copy. Carries everything: Docker, apt packages,
`/etc`. Nothing to rebuild. It writes an uncompressed tar roughly the size of
used disk, so free space is needed on both ends, and it is all-or-nothing — a
copy that dies at 80% starts over.

```powershell
wsl --shutdown
wsl --export Ubuntu D:\ubuntu.tar
wsl --import Ubuntu C:\WSL\Ubuntu D:\ubuntu.tar --version 2
```

The exported tar holds `~/.ssh` and every `.env`. Treat it as a secret.

**rsync over ssh.** About 2 hours: a short copy, then an hour rebuilding apt
packages and Docker by hand. It moves files only, so it is really the
"rebuild fresh" route with a faster copy step. Worth it when the switch is
gradual, because it is incremental and resumable — sync once, keep working,
sync again on the day.

```bash
rsync -aHAX --info=progress2 \
  --exclude 'node_modules/' --exclude '.npm/' --exclude '.cache/' \
  ~/ alex@NEW_IP:/home/alex/
```

Home is 19 G but only 6 G after those excludes. Use `-a`, never `-L`: the
dotfiles are stow symlinks, and `-L` would follow them and duplicate 1.8 G.

Mirrored networking means WSL already has a real LAN address, so ssh reaches it
with no `netsh portproxy`. Install `openssh-server` first — it is not in the
package list.

Trim before either route. Deleting `node_modules`, `~/.npm` and `~/.cache` takes
23 G down to about 12 G, and `npm i` rebuilds them.

## Traps

- **uid must match.** The user here is uid 1000. A fresh Ubuntu gives its first
  user 1000 too, so rsynced files land with correct ownership. Make the user
  first, before copying anything.
- **Do not rsync `/var/lib/docker`.** The overlay2 storage does not survive a
  file copy. Use `pg_dump` and re-pull the image.
- **`~/.local` is folded into this repo.** Stow folds it to `bin/.local` when
  `~/.local` does not exist yet, so nvim plugins and the trash land here.
  `.gitignore` already covers `bin/.local/share/` and `bin/.local/state/`.
- **Neovim needs the real `psql`.** vim-dadbod shells out to it. Without
  `postgresql-client` the sidebar lists connections but opening one fails.
