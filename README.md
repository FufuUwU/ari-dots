# Ari-Dots

Personal Linux configuration repository containing dotfiles, system configuration, package manifests and installation scripts.

The goal is to keep system configuration version-controlled, reproducible and easy to deploy on a fresh installation.

> **Status:** Work in progress. Gentoo and Arch Linux are the intended supported distributions.

## Features

- Home directory configuration managed through symbolic links.
- Separate package manifests for Gentoo and Arch Linux.
- Distribution-specific package installation scripts.
- Distribution-specific system configuration exporters.
- Shared dotfile installation and uninstallation.
- Dry-run support for installation and export operations.
- Automatic backups of conflicting files before replacing them with symlinks.

## Repository structure

```text
ari-dots/
├── docs/
├── home/
│   ├── .bashrc
│   ├── .bash_profile
│   ├── .bash_logout
│   ├── .config/
│   └── .local/bin/
├── packages/
│   ├── arch/
│   │   ├── apps.txt
│   │   ├── aur.txt
│   │   ├── base.txt
│   │   └── desktop.txt
│   └── gentoo/
│       ├── apps.txt
│       ├── base.txt
│       └── desktop.txt
├── scripts/
├── system/
│   ├── arch/
│   ├── gentoo/
│   │   └── portage/
│   ├── sddm/
│   └── tuned/
├── export-arch.sh
├── export-gentoo.sh
├── install-arch.sh
├── install-gentoo.sh
├── install.sh
├── uninstall.sh
└── README.md
```

## Requirements

### General

- Bash
- GNU core utilities
- Findutils
- `sudo`

### Gentoo

- Gentoo Linux
- Portage (`emerge`)
- Configured Portage repositories

### Arch Linux

- Arch Linux
- `pacman`
- Configured package repositories

AUR packages are tracked separately in `packages/arch/aur.txt` and are not automatically installed by the official package installer.

## Installation

Clone the repository and enter its directory:

```bash
git clone <repository-url> ari-dots
cd ari-dots
```

### Dotfiles

Preview the dotfile installation:

```bash
./install.sh --dry-run
```

Install the dotfiles:

```bash
./install.sh
```

The shared installer creates symbolic links from the repository into the home directory.

Existing conflicting files and symlinks are backed up under:

```text
~/.local/state/ari-dots-backups/
```

Existing files that are already correctly linked are left untouched.

## Package installation

Package installation is handled by separate distribution-specific scripts.

### Gentoo

Preview the package transaction:

```bash
./install-gentoo.sh --dry-run
```

Install packages:

```bash
./install-gentoo.sh
```

The installer reads every `.txt` manifest in `packages/gentoo/` and passes the listed packages to Portage.

### Arch Linux

Preview the package transaction:

```bash
./install-arch.sh --dry-run
```

Install packages:

```bash
./install-arch.sh
```

The installer reads the official repository package manifests in `packages/arch/` and passes the listed packages to pacman.

AUR packages are kept separate in `packages/arch/aur.txt` and require a separate AUR helper or manual installation.

> **Note:** Arch package manifests are currently being populated. The Arch package installer will not install anything until official package entries have been added.

Package installation is separate from dotfile installation.

## Exporting system configuration

System configuration exporters copy selected live system configuration files into the repository.

They are distribution-specific.

### Gentoo

Preview the export:

```bash
./export-gentoo.sh --dry-run
```

Perform the export:

```bash
./export-gentoo.sh
```

The Gentoo exporter handles selected configuration from:

- `/etc/portage/`
- `/etc/sddm.conf.d/`
- `/etc/tuned/`
- `/usr/share/sddm/themes/moon/`

### Arch Linux

Preview the export:

```bash
./export-arch.sh --dry-run
```

Perform the export:

```bash
./export-arch.sh
```

The Arch exporter handles selected configuration from:

- `/etc/pacman.conf`
- `/etc/sddm.conf.d/`
- `/etc/tuned/`
- `/usr/share/sddm/themes/moon/`

Exporters are additive: they update or create repository files, but do not automatically delete files that have been removed from the live system.

Review exported changes before committing them.

## Uninstallation

Run:

```bash
./uninstall.sh
```

The uninstaller removes symbolic links managed by this repository.

It does not delete repository files or automatically restore previous configurations. Backups remain available under:

```text
~/.local/state/ari-dots-backups/
```

Restore previous files manually if required.

## Command reference

| Command | Description |
|---|---|
| `./install.sh` | Install home directory configurations |
| `./install.sh --dry-run` | Preview dotfile installation |
| `./install.sh --help` | Display shared installer help |
| `./install-gentoo.sh` | Install Gentoo packages |
| `./install-gentoo.sh --dry-run` | Preview Gentoo package installation |
| `./install-arch.sh` | Install Arch packages |
| `./install-arch.sh --dry-run` | Preview Arch package installation |
| `./export-gentoo.sh` | Export Gentoo system configuration |
| `./export-gentoo.sh --dry-run` | Preview Gentoo configuration export |
| `./export-arch.sh` | Export Arch system configuration |
| `./export-arch.sh --dry-run` | Preview Arch configuration export |
| `./uninstall.sh` | Remove repository-managed symlinks |

## Notes

- Home directory configuration is shared between distributions wherever possible.
- Distribution-specific package manifests and system configuration are kept separate.
- Gentoo-specific Portage settings are stored under `system/gentoo/`.
- Machine-specific Portage settings are separated into `make.conf.local`.
- System configuration files are exported into the repository; they are not automatically deployed by the home dotfile installer.
- Package installation and system configuration export must be run separately.
- Review personal assets, font licensing and configuration contents before publishing this repository.

## License

No repository-wide license has been selected yet. Individual assets and bundled fonts may have their own licensing requirements.
