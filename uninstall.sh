#!/bin/sh
set -e

# LBMesh uninstaller.
#
# Usage:
#   curl -fsSL https://get.lbmesh.io/uninstall.sh | sh
#   curl -fsSL https://get.lbmesh.io/uninstall.sh | sh -s -- --purge
#
# Options:
#   --purge       Also delete ~/.lbmesh (config, state, catalogs, taps, projects) without asking
#   --keep-data   Keep ~/.lbmesh without asking
#   --force       Continue even if LBMesh instances appear to be running
#   -h, --help    Show this help

usage() {
    cat <<'EOF'
Usage: uninstall.sh [--purge | --keep-data] [--force]

  --purge       Also delete ~/.lbmesh (config, state, catalogs, taps, projects) without asking
  --keep-data   Keep ~/.lbmesh without asking
  --force       Continue even if LBMesh instances appear to be running
  -h, --help    Show this help
EOF
}

DATA_DIR="${HOME}/.lbmesh"
DATA_MODE="ask"
FORCE=0

for arg in "$@"; do
    case "$arg" in
        --purge)     DATA_MODE="purge" ;;
        --keep-data) DATA_MODE="keep" ;;
        --force)     FORCE=1 ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: unknown option '$arg'." >&2
            exit 1
            ;;
    esac
done

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: do not run this as root; it would target root's home directory." >&2
    echo "The script uses sudo only when it needs to remove a protected binary." >&2
    exit 1
fi

# Remove a file, falling back to sudo when the directory is not writable.
remove_file() {
    if [ -w "$(dirname "$1")" ]; then
        rm -f "$1"
    else
        echo "Removing $1 (requires sudo)..."
        sudo rm -f "$1"
    fi
}

# Read a yes/no answer from the terminal, even when the script is piped into sh.
# Returns 1 (no) when there is no terminal available.
confirm() {
    if [ -r /dev/tty ] && [ -w /dev/tty ]; then
        printf '%s [y/N] ' "$1" > /dev/tty
        read -r answer < /dev/tty || answer=""
        case "$answer" in
            y|Y|yes|YES) return 0 ;;
        esac
    fi
    return 1
}

# 1. Make sure nothing is still running
if command -v lbmesh >/dev/null 2>&1; then
    STATUS=$(lbmesh status 2>&1 || true)
    case "$STATUS" in
        *"no running instances"*) ;;
        *)
            if [ "$FORCE" -ne 1 ]; then
                echo "LBMesh appears to have running instances:" >&2
                echo "$STATUS" >&2
                echo >&2
                echo "Stop them first with 'lbmesh down <recipe>', or re-run with --force." >&2
                exit 1
            fi
            echo "Warning: continuing with running instances (--force)."
            ;;
    esac
fi

# 2. Remove the binary (Homebrew install and/or install.sh install)
FOUND=0

if command -v brew >/dev/null 2>&1 && brew list lbmesh >/dev/null 2>&1; then
    echo "Removing Homebrew package lbmesh..."
    brew uninstall lbmesh
    FOUND=1
fi

PATH_BIN=$(command -v lbmesh 2>/dev/null || true)
for bin in /usr/local/bin/lbmesh "${HOME}/.local/bin/lbmesh" "$PATH_BIN"; do
    if [ -n "$bin" ] && { [ -e "$bin" ] || [ -L "$bin" ]; }; then
        echo "Removing binary $bin..."
        remove_file "$bin"
        FOUND=1
    fi
done

if [ "$FOUND" -eq 0 ]; then
    echo "No LBMesh binary found."
fi

# 3. Remove user data
if [ -d "$DATA_DIR" ]; then
    if [ "$DATA_MODE" = "ask" ]; then
        if confirm "Delete LBMesh data in ${DATA_DIR} (config, state, catalogs, taps, projects)?"; then
            DATA_MODE="purge"
        else
            DATA_MODE="keep"
        fi
    fi

    if [ "$DATA_MODE" = "purge" ]; then
        rm -rf "$DATA_DIR"
        echo "Deleted ${DATA_DIR}."
    else
        echo "Kept ${DATA_DIR}. Re-run with --purge for a fully clean removal."
    fi
fi

echo "LBMesh uninstall complete."
