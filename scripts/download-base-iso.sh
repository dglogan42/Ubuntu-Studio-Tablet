#!/usr/bin/env bash
# Download official Ubuntu Studio 26.04 ISO into iso/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO_DIR="$ROOT/iso"
BASE_URL="https://cdimage.ubuntu.com/ubuntustudio/releases/resolute/release"
ISO_NAME="ubuntustudio-26.04-desktop-amd64.iso"
DEST="$ISO_DIR/$ISO_NAME"

mkdir -p "$ISO_DIR"
cd "$ISO_DIR"

echo "Target: $DEST"
echo "Need ~7 GB free for ISO + ~15 GB for remaster."
df -h "$ISO_DIR" | tail -1

if [[ -f "$DEST" ]]; then
  echo "ISO already present: $DEST"
  ls -lh "$DEST"
  exit 0
fi

if command -v wget >/dev/null; then
  wget -c "$BASE_URL/$ISO_NAME" -O "$DEST.partial"
  mv "$DEST.partial" "$DEST"
elif command -v curl >/dev/null; then
  curl -L -C - -o "$DEST.partial" "$BASE_URL/$ISO_NAME"
  mv "$DEST.partial" "$DEST"
else
  echo "Need wget or curl" >&2
  exit 1
fi

echo "Downloading checksums..."
wget -q -O SHA256SUMS "$BASE_URL/SHA256SUMS" || curl -fsSL -o SHA256SUMS "$BASE_URL/SHA256SUMS"
if command -v sha256sum >/dev/null && [[ -f SHA256SUMS ]]; then
  grep "$ISO_NAME" SHA256SUMS | sha256sum -c - || {
    echo "Checksum FAILED" >&2
    exit 1
  }
fi

ls -lh "$DEST"
echo "Done. Next: sudo ./scripts/remaster-iso.sh"
