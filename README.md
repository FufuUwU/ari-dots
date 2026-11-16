# Ari-Dots

Personal Linux dotfiles and system configuration for Arch Linux and Gentoo.

## Installation order

1. `install-arch.sh` / `install-gentoo.sh` — install packages for the current distribution.
2. Install AUR packages separately on Arch using `yay`.
3. `install.sh` — link dotfiles and configuration files into your home directory. Existing files are backed up automatically.

Use `--dry-run` to preview changes before applying them.

## Scripts

- `install.sh` — installs home configuration and scripts.
- `install-arch.sh` — installs official Arch packages.
- `install-gentoo.sh` — installs Gentoo packages.
- `export-arch.sh` — exports Arch system configuration into the repository.
- `export-gentoo.sh` — exports Gentoo system configuration into the repository.
- `uninstall.sh` — removes Ari-Dots symlinks. Backups and repository files are kept.

## Package lists

### Arch — `packages/arch/`

- `base.txt` — essential system packages.
- `desktop.txt` — desktop environment and Wayland utilities.
- `apps.txt` — applications and everyday utilities.
- `aur.txt` — packages installed from the AUR.
- `all-packages.txt` — snapshot of every installed package.
- `repo-packages.txt` — snapshot of official repository packages.
- `foreign-packages.txt` — snapshot of AUR and foreign packages.
- `dev-packages.txt` — development tools.

### Gentoo — `packages/gentoo/`

- `base.txt` — essential system packages.
- `desktop.txt` — desktop environment and utilities.
- `apps.txt` — applications and everyday utilities.

## Manual package management

Install packages from a list:

```bash
grep -Ev '^[[:space:]]*(#|$)' packages/arch/base.txt |
  xargs -r sudo pacman -S --needed
```

Remove packages from a list:

```bash
grep -Ev '^[[:space:]]*(#|$)' packages/arch/base.txt |
  xargs -r sudo pacman -R
```

Replace `base.txt` with the desired package list.

**Note:** Package snapshots are for reference or restoring an existing package set. Review them before installing or removing packages.
