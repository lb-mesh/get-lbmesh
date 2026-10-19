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

# 2. Dynamically Fetch the Latest Release Tag from GitHub API
# Eliminates the need to manually update this script when you release a new version!
echo "Checking latest release version of LBMesh..."
LATEST_TAG=$(curl -s https://api.github.com/repos/lb-mesh/lbmesh/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    # Fallback default if GitHub API is throttled
    LATEST_TAG="v1.0.4"
fi

echo "Installing LBMesh ${LATEST_TAG} for ${OS}/${ARCH}..."

# 3. Construct Binary Download URL (Matches GoReleaser Asset Standards)
BINARY_URL="https://github.com/lb-mesh/lbmesh/releases/download/${LATEST_TAG}/lbmesh_${OS}_${ARCH}.tar.gz"

# 4. Download, Unpack, and Install to /usr/local/bin
TMP_DIR=$(mktemp -d)
curl -sSL "$BINARY_URL" -o "${TMP_DIR}/lbmesh.tar.gz"
tar -xzf "${TMP_DIR}/lbmesh.tar.gz" -C "$TMP_DIR"

echo "Installing binary to /usr/local/bin/lbmesh (requires sudo)..."
sudo mv "${TMP_DIR}/lbmesh" /usr/local/bin/lbmesh
chmod +x /usr/local/bin/lbmesh

# 5. Run silent initialization to scaffold folders immediately
/usr/local/bin/lbmesh init

echo "LBMesh successfully installed! Run 'lbmesh status' or 'lbmesh dashboard' to begin."
