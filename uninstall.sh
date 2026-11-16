#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

remove_link() {
    local src="$1"
    local dest="$2"
    local src_real dest_real

    [[ -L "$dest" ]] || return 0

    src_real="$(readlink -f "$src")"
    dest_real="$(readlink -f "$dest" 2>/dev/null || true)"

    if [[ "$dest_real" == "$src_real" ]]; then
        echo "Removing link: $dest"
        rm -- "$dest"
    fi
}

echo "========== ARI-DOTS UNINSTALLER =========="
echo "This removes links pointing into this repository."
echo "It does not delete repository files or backup directories."
echo

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    [[ "$name" == ".config" || "$name" == ".local" ]] && continue
    remove_link "$src" "$HOME/$name"
done < <(find "$ROOT/home" -mindepth 1 -maxdepth 1 -print0)

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    remove_link "$src" "$HOME/.config/$name"
done < <(find "$ROOT/home/.config" -mindepth 1 -maxdepth 1 -print0)

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    remove_link "$src" "$HOME/.local/bin/$name"
done < <(find "$ROOT/home/.local/bin" -mindepth 1 -maxdepth 1 -type f -print0)

echo
echo "Uninstallation finished."
echo "Previously backed-up files remain in ~/.local/state/ari-dots-backups/"
