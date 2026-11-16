#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0

usage() {
    cat <<'HELP'
Usage: ./install-gentoo.sh [OPTIONS]

Options:
  --dry-run    Preview the package transaction
  --help       Show this help message

Examples:
  ./install-gentoo.sh
  ./install-gentoo.sh --dry-run
HELP
}

while (($#)); do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

echo "========== ARI-DOTS GENTOO PACKAGE INSTALLER =========="
echo "Repository: $ROOT"

if [[ ! -e /etc/gentoo-release ]]; then
    echo "ERROR: This does not appear to be a Gentoo system." >&2
    exit 1
fi

if ! command -v emerge >/dev/null 2>&1; then
    echo "ERROR: emerge was not found." >&2
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "ERROR: sudo was not found." >&2
    exit 1
fi

if (( DRY_RUN )); then
    echo "DRY RUN: no packages will be installed."
fi

shopt -s nullglob
manifests=("$ROOT"/packages/gentoo/*.txt)
shopt -u nullglob

if ((${#manifests[@]} == 0)); then
    echo "ERROR: No Gentoo package manifests found." >&2
    exit 1
fi

packages=()

for manifest in "${manifests[@]}"; do
    echo "Reading: ${manifest#"$ROOT"/}"

    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ "$package" =~ ^[[:space:]]*(#|$) ]] && continue
        packages+=("$package")
    done < "$manifest"
done

if ((${#packages[@]} == 0)); then
    echo "ERROR: No packages found in manifests." >&2
    exit 1
fi

echo
echo "Packages selected: ${#packages[@]}"

if (( DRY_RUN )); then
    sudo emerge --pretend --getbinpkg --usepkg --verbose "${packages[@]}"
else
    sudo emerge -av --getbinpkg --usepkg "${packages[@]}"
fi

echo
echo "Package operation finished."
