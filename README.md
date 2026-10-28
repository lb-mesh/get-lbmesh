# LBMesh Quick Installer Subsystem (`get-lbmesh`)

This repository hosts the official, unified single-line shell installer for **LBMesh** — the autonomous local container and AI-orchestration platform. 

The installation script is served globally with TLS encryption via GitHub Pages at:
👉 **[https://get.lbmesh.io](https://get.lbmesh.io)**

---

## 🚀 Quick Install

To install the latest pre-compiled static binary of LBMesh on macOS (Apple Silicon/Intel), Linux (AMD64/ARM64), or Windows WSL2, execute the following command in your terminal:

```bash
curl -fsSL https://get.lbmesh.io | sh
```

---

## 🧹 Uninstall

Removes the LBMesh binary (Homebrew or `/usr/local/bin`) and, if you confirm, the `~/.lbmesh` data directory:

```bash
curl -fsSL https://get.lbmesh.io/uninstall.sh | sh
```

For a fully clean removal with no prompts (ready for a fresh install):

```bash
curl -fsSL https://get.lbmesh.io/uninstall.sh | sh -s -- --purge
```

Options: `--purge` (delete `~/.lbmesh`), `--keep-data` (keep it), `--force` (proceed even if instances are running).
Stop running recipes first with `lbmesh down <recipe>`.
