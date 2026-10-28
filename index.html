#!/bin/sh
set -e

# 1. Identify Host OS and CPU Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
else
    echo "Error: Unsupported CPU architecture ($ARCH)." >&2
    exit 1
fi

case "$OS" in
    darwin|linux) ;;
    *)
        echo "Error: LBMesh is currently supported on Darwin and Linux host architectures." >&2
        exit 1
        ;;
esac

# 2. Fetch the latest release tag.
# Primary: GitHub API. Fallback: follow the /releases/latest redirect, which is not
# subject to API rate limits. No version is hardcoded, so this never goes stale.
echo "Checking latest release version of LBMesh..."
LATEST_TAG=$(curl -fsS https://api.github.com/repos/lb-mesh/lbmesh/releases/latest 2>/dev/null \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || true)

if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG=$(curl -fsSL -o /dev/null -w '%{url_effective}' https://github.com/lb-mesh/lbmesh/releases/latest 2>/dev/null \
        | sed -E 's#.*/tag/##' || true)
fi

case "$LATEST_TAG" in
    v[0-9]*) ;;
    *)
        echo "Error: could not determine the latest LBMesh release. Check your network and try again." >&2
        exit 1
        ;;
esac

# 3. Detect an existing install
EXISTING=$(command -v lbmesh 2>/dev/null || true)

if [ -n "$EXISTING" ]; then
    # Leave Homebrew-managed installs to Homebrew so we never create a second, shadowed copy.
    if command -v brew >/dev/null 2>&1 && brew list lbmesh >/dev/null 2>&1; then
        echo "LBMesh is managed by Homebrew (${EXISTING})."
        echo "Latest release is ${LATEST_TAG}. To upgrade, run: brew upgrade lbmesh"
        exit 0
    fi

    CURRENT=$("$EXISTING" version 2>/dev/null | head -n 1 | awk '{print $2}' || true)
    if [ -n "$CURRENT" ] && [ "v${CURRENT#v}" = "$LATEST_TAG" ]; then
        echo "LBMesh ${LATEST_TAG} is already installed (${EXISTING}). Nothing to do."
        exit 0
    fi

    # Upgrade in place, wherever the existing binary lives.
    DEST="$EXISTING"
    [ -n "$CURRENT" ] && echo "Upgrading LBMesh ${CURRENT} -> ${LATEST_TAG} for ${OS}/${ARCH}..."
else
    DEST="/usr/local/bin/lbmesh"
    echo "Installing LBMesh ${LATEST_TAG} for ${OS}/${ARCH}..."
fi

# 4. Construct Binary Download URL (Matches GoReleaser Asset Standards)
BINARY_URL="https://github.com/lb-mesh/lbmesh/releases/download/${LATEST_TAG}/lbmesh_${LATEST_TAG#v}_${OS}_${ARCH}.tar.gz"

# 5. Download and unpack
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "$BINARY_URL" -o "${TMP_DIR}/lbmesh.tar.gz"
tar -xzf "${TMP_DIR}/lbmesh.tar.gz" -C "$TMP_DIR"
chmod +x "${TMP_DIR}/lbmesh"

# 6. Install, using sudo only when the destination is not writable
DEST_DIR=$(dirname "$DEST")
if [ -d "$DEST_DIR" ] && [ -w "$DEST_DIR" ]; then
    mv "${TMP_DIR}/lbmesh" "$DEST"
else
    echo "Installing binary to ${DEST} (requires sudo)..."
    sudo mkdir -p "$DEST_DIR"
    sudo mv "${TMP_DIR}/lbmesh" "$DEST"
fi

# 7. Run silent initialization to scaffold folders (keeps any existing config)
"$DEST" init

echo "LBMesh ${LATEST_TAG} successfully installed! Run 'lbmesh status' or 'lbmesh dashboard' to begin."
