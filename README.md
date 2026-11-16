
# Ari-Dots

Personal Linux configuration repository containing dotfiles, system configuration, package manifests and installation scripts.

The goal is to keep system configuration version-controlled, reproducible and easy to deploy on a fresh installation.

> **Status:** Work in progress. Gentoo is currently the first supported distribution. Support for additional distributions is planned.

## Features

- Home directory configuration managed through symbolic links.
- System configuration snapshots for Gentoo, SDDM and TuneD.
- Gentoo package manifests.
- Installation, uninstallation and configuration export scripts.
- Dry-run support for installation and package operations.
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
│   └── gentoo/
│       ├── apps.txt
│       ├── base.txt
│       └── desktop.txt
├── system/
│   ├── gentoo/portage/
│   ├── sddm/
│   └── tuned/
├── export.sh
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

### Gentoo package installation

- Gentoo Linux
- Portage (`emerge`)
- Configured Portage repositories

The package installer currently supports Gentoo manifests only.

## Installation

Clone the repository and enter its directory:

```bash
git clone <repository-url> ari-dots
cd ari-dots
```

Preview the dotfile installation:

```bash
./install.sh --dry-run
```

Install the dotfiles:

```bash
./install.sh
```

The installer creates symbolic links from the repository into the home directory.

Existing conflicting files and symlinks are backed up under:

```text
~/.local/state/ari-dots-backups/
```

Existing files that are already correctly linked are left untouched.

## Package installation

Preview the Gentoo package transaction:

```bash
./install.sh --packages --dry-run
```

Install packages from all Gentoo manifests:

```bash
./install.sh --packages
```

The package installer reads every `.txt` manifest in `packages/gentoo/` and passes the listed packages to Portage.

Package installation is separate from dotfile installation.

## Exporting system configuration

`export.sh` copies selected live system configuration files into the repository.

Preview the export:

```bash
./export.sh --dry-run
```

Perform the export:

```bash
./export.sh
```

The exporter currently handles selected configuration from:

- `/etc/portage/`
- `/etc/sddm.conf.d/`
- `/etc/tuned/`
- `/usr/share/sddm/themes/moon/`

The exporter is additive: it updates or creates repository files, but does not automatically delete files that have been removed from the live system.

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
| `./install.sh --packages` | Install Gentoo packages |
| `./install.sh --packages --dry-run` | Preview package installation |
| `./install.sh --help` | Display installer help |
| `./export.sh` | Export selected system configuration |
| `./export.sh --dry-run` | Preview configuration export |
| `./uninstall.sh` | Remove repository-managed symlinks |

## Notes

- System configuration is stored separately from home directory configuration.
- Gentoo-specific Portage settings are kept under `system/gentoo/`.
- Machine-specific Portage settings are separated into `make.conf.local`.
- System configuration files are exported into the repository; they are not automatically deployed by the home dotfile installer.
- Distribution detection and support for additional package managers are planned, but are not implemented yet.
- Review personal assets, font licensing and configuration contents before publishing this repository.

## License

No repository-wide license has been selected yet. Individual assets and bundled fonts may have their own licensing requirements.
