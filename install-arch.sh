#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0

usage() {
    cat <<'HELP'
Usage: ./install-arch.sh [OPTIONS]

Options:
  --dry-run    Preview the package transaction
  --help       Show this help message

Examples:
  ./install-arch.sh
  ./install-arch.sh --dry-run
HELP
}

while (($#)); do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        --help|-h) usage; exit 0 ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

echo "========== ARI-DOTS ARCH PACKAGE INSTALLER =========="
echo "Repository: $ROOT"

if [[ ! -r /etc/arch-release ]]; then
    echo "ERROR: This does not appear to be an Arch Linux system." >&2
    exit 1
fi

for command in pacman sudo; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERROR: $command was not found." >&2
        exit 1
    fi
done

shopt -s nullglob
manifests=("$ROOT"/packages/arch/*.txt)
shopt -u nullglob

if ((${#manifests[@]} == 0)); then
    echo "ERROR: No Arch package manifests found." >&2
    exit 1
fi

packages=()

for manifest in "${manifests[@]}"; do
    [[ "$(basename "$manifest")" == "aur.txt" ]] && continue

    echo "Reading: ${manifest#"$ROOT"/}"

    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ "$package" =~ ^[[:space:]]*(#|$) ]] && continue
        packages+=("$package")
    done < "$manifest"
done

if ((${#packages[@]} == 0)); then
    echo "ERROR: No official Arch packages found in manifests." >&2
    exit 1
fi

echo
echo "Official repository packages selected: ${#packages[@]}"

if (( DRY_RUN )); then
    echo "DRY RUN: resolving packages without installing them."
    sudo pacman -Sp --needed "${packages[@]}"
else
    sudo pacman -S --needed "${packages[@]}"
fi

echo
echo "Package operation finished."
echo "AUR packages, if any, are listed separately in packages/arch/aur.txt."
echo "They are not installed automatically by this script."
