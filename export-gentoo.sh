#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OWNER="$(id -un)"
GROUP="$(id -gn)"
DRY_RUN=0

case "${1:-}" in
    "")
        ;;
    --dry-run)
        DRY_RUN=1
        ;;
    *)
        echo "Usage: ./export-gentoo.sh [--dry-run]"
        exit 1
        ;;
esac

export_file() {
    local src="$1"
    local dest="$2"

    if [[ ! -f "$src" ]]; then
        echo "Skipping missing file: $src"
        return 0
    fi

    if (( DRY_RUN )); then
        printf 'WOULD EXPORT: %s -> %s\n' "$src" "$dest"
    else
        sudo install -D -m 0644 -o "$OWNER" -g "$GROUP" \
            -- "$src" "$dest"
        printf 'EXPORTED: %s\n' "$dest"
    fi
}

export_tree() {
    local source_dir="$1"
    local dest_dir="$2"
    local src relative

    if [[ ! -d "$source_dir" ]]; then
        echo "Skipping missing directory: $source_dir"
        return 0
    fi

    while IFS= read -r -d '' src; do
        relative="${src#"$source_dir"/}"
        export_file "$src" "$dest_dir/$relative"
    done < <(
        find "$source_dir" -type f \
            ! -name '._cfg*' \
            ! -name '*.bak' \
            -print0 | sort -z
    )
}

echo "========== ARI-DOTS SYSTEM EXPORT =========="
echo "Repository: $ROOT"

if (( DRY_RUN )); then
    echo "DRY RUN: no files will be changed."
fi

echo
echo "========== SDDM CONFIGURATION =========="

for file in moon.conf 01gentoo.conf; do
    export_file \
        "/etc/sddm.conf.d/$file" \
        "$ROOT/system/sddm/configs/$file"
done

echo
echo "========== SDDM MOON THEME =========="

export_tree \
    "/usr/share/sddm/themes/moon" \
    "$ROOT/system/sddm/moon"

echo
echo "========== TUNED CONFIGURATION =========="

for file in ppd.conf tuned-main.conf profile_mode ppd_base_profile; do
    export_file \
        "/etc/tuned/$file" \
        "$ROOT/system/tuned/$file"
done

echo
echo "========== GENTOO PORTAGE =========="

export_file \
    "/etc/portage/make.conf" \
    "$ROOT/system/gentoo/portage/make.conf"

export_file \
    "/etc/portage/make.conf.local" \
    "$ROOT/system/gentoo/portage/make.conf.local"

for dir in package.use package.accept_keywords package.license repos.conf binrepos.conf; do
    export_tree \
        "/etc/portage/$dir" \
        "$ROOT/system/gentoo/portage/$dir"
done

echo
echo "========== EXPORT COMPLETE =========="

if (( DRY_RUN )); then
    echo "Preview only. Run ./export-gentoo.sh to perform the export."
else
    echo "System configuration exported to the repository."
fi
