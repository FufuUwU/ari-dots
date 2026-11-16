#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/ari-dots-backups/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

usage() {
    cat <<'HELP'
Usage: ./install.sh [OPTIONS]

Options:
  --dry-run    Preview without making changes
  --help       Show this help message

Examples:
  ./install.sh
  ./install.sh --dry-run
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

run() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'
    if (( ! DRY_RUN )); then
        "$@"
    fi
}

link_item() {
    local src="$1"
    local dest="$2"
    local src_real dest_real relative backup

    src_real="$(readlink -f "$src")"

    if [[ -L "$dest" ]]; then
        dest_real="$(readlink -f "$dest" 2>/dev/null || true)"
        if [[ "$dest_real" == "$src_real" ]]; then
            echo "Already linked: $dest"
            return
        fi
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        relative="${dest#"$HOME"/}"
        backup="$BACKUP_ROOT/$relative"

        if [[ -e "$backup" || -L "$backup" ]]; then
            echo "ERROR: Backup already exists: $backup" >&2
            exit 1
        fi

        echo "Backing up: $dest"
        run mkdir -p "$(dirname "$backup")"
        run mv -- "$dest" "$backup"
    fi

    run mkdir -p "$(dirname "$dest")"
    run ln -s -- "$src" "$dest"
    echo "Linked: $dest"
}

echo "========== ARI-DOTS SHARED INSTALLER =========="
echo "Repository: $ROOT"
echo "Backup location: $BACKUP_ROOT"

if (( DRY_RUN )); then
    echo "DRY RUN: no changes will be made."
fi

echo
echo "========== HOME DOTFILES =========="

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    [[ "$name" == ".config" || "$name" == ".local" ]] && continue
    link_item "$src" "$HOME/$name"
done < <(find "$ROOT/home" -mindepth 1 -maxdepth 1 -print0)

echo
echo "========== CONFIGURATION DIRECTORIES AND FILES =========="

run mkdir -p "$HOME/.config"

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    link_item "$src" "$HOME/.config/$name"
done < <(find "$ROOT/home/.config" -mindepth 1 -maxdepth 1 -print0)

echo
echo "========== LOCAL BIN SCRIPTS =========="

run mkdir -p "$HOME/.local/bin"

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    link_item "$src" "$HOME/.local/bin/$name"
done < <(find "$ROOT/home/.local/bin" -mindepth 1 -maxdepth 1 -type f -print0)

echo
echo "========== COMPLETE =========="
if (( DRY_RUN )); then
    echo "Dry run finished. Run ./install.sh to apply."
else
    echo "Installation finished."
fi
