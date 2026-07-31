#!/usr/bin/env bash
# Remaster Ubuntu Studio 26.04 ISO with tablet layer
# Requires: root, xorriso, squashfs-tools, rsync, ~20GB free
set -euo pipefail

if [[ "${EUID:-}" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ISO_DIR="$ROOT/iso"
WORK="$ISO_DIR/work"
SRC_ISO="${SRC_ISO:-$ISO_DIR/ubuntustudio-26.04-desktop-amd64.iso}"
OUT_ISO="${OUT_ISO:-$ISO_DIR/ubuntu-studio-tablet-26.04-amd64.iso}"
MNT="$WORK/mnt"
EXTRACT="$WORK/extract"
SQUASH_MNT="$WORK/squash-mnt"
EDIT="$WORK/edit"

need() { command -v "$1" >/dev/null || { echo "Missing tool: $1" >&2; exit 1; }; }
need xorriso
need mksquashfs
need unsquashfs
need rsync
need mount

if [[ ! -f "$SRC_ISO" ]]; then
  echo "Base ISO not found: $SRC_ISO" >&2
  echo "Run: ./scripts/download-base-iso.sh" >&2
  exit 1
fi

echo "==> Free space check..."
avail_kb=$(df -k "$ISO_DIR" | awk 'NR==2{print $4}')
if [[ "$avail_kb" -lt 15000000 ]]; then
  echo "WARNING: less than ~15GB free; remaster may fail (avail ${avail_kb}KB)"
fi

rm -rf "$WORK"
mkdir -p "$MNT" "$EXTRACT" "$SQUASH_MNT" "$EDIT"

cleanup() {
  umount "$SQUASH_MNT" 2>/dev/null || true
  umount "$MNT" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Mounting ISO..."
mount -o loop,ro "$SRC_ISO" "$MNT"
rsync -a "$MNT/" "$EXTRACT/"
umount "$MNT"

SQUASH=$(find "$EXTRACT" -name 'filesystem.squashfs' | head -1)
if [[ -z "$SQUASH" ]]; then
  echo "filesystem.squashfs not found in ISO layout" >&2
  find "$EXTRACT" -name '*.squashfs' | head
  exit 1
fi
SQUASH_DIR=$(dirname "$SQUASH")

echo "==> Extracting squashfs (slow)..."
unsquashfs -d "$EDIT" "$SQUASH"

echo "==> Injecting Ubuntu Studio Tablet layer..."
mkdir -p "$EDIT/opt/ubuntu-studio-tablet"
rsync -a --exclude iso --exclude work "$ROOT/" "$EDIT/opt/ubuntu-studio-tablet/"

# Chroot install
cp /etc/resolv.conf "$EDIT/etc/resolv.conf"
mount --bind /dev "$EDIT/dev"
mount --bind /proc "$EDIT/proc"
mount --bind /sys "$EDIT/sys"
mount -t devpts devpts "$EDIT/dev/pts" 2>/dev/null || true

cat >"$EDIT/tmp/ust-chroot-install.sh" <<'CHROOT'
#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export HOME=/root
cd /opt/ubuntu-studio-tablet
chmod +x scripts/*.sh scripts/ust-* 2>/dev/null || true
# Prefer non-interactive install
bash scripts/install-tablet-mode.sh || true
bash scripts/setup-chinese.sh || true
# Clean apt caches to shrink
apt-get clean
rm -rf /var/lib/apt/lists/*
CHROOT
chmod +x "$EDIT/tmp/ust-chroot-install.sh"

echo "==> Running chroot install..."
chroot "$EDIT" /tmp/ust-chroot-install.sh || {
  echo "WARN: chroot install returned non-zero; continuing with file inject only"
}

# Ensure files present even if apt failed offline
chroot "$EDIT" bash -c '
  mkdir -p /usr/lib/ubuntu-studio-tablet/bin /usr/share/ubuntu-studio-tablet/desktop
  install -m 0755 /opt/ubuntu-studio-tablet/scripts/ust-launch /usr/lib/ubuntu-studio-tablet/bin/
  install -m 0755 /opt/ubuntu-studio-tablet/scripts/ust-session-init /usr/lib/ubuntu-studio-tablet/bin/
  install -m 0755 /opt/ubuntu-studio-tablet/scripts/ust-start-session /usr/lib/ubuntu-studio-tablet/bin/
  install -m 0755 /opt/ubuntu-studio-tablet/scripts/ust-home-launcher /usr/lib/ubuntu-studio-tablet/bin/ 2>/dev/null || true
  bash /opt/ubuntu-studio-tablet/scripts/generate-app-desktops.sh /usr/share/ubuntu-studio-tablet/desktop
  cp /usr/share/ubuntu-studio-tablet/desktop/*.desktop /usr/share/applications/ 2>/dev/null || true
  cp -a /opt/ubuntu-studio-tablet/configs/plasma/* /etc/skel/.config/ 2>/dev/null || mkdir -p /etc/skel/.config && cp -a /opt/ubuntu-studio-tablet/configs/plasma/* /etc/skel/.config/
'

umount "$EDIT/dev/pts" 2>/dev/null || true
umount "$EDIT/dev" "$EDIT/proc" "$EDIT/sys" 2>/dev/null || true

echo "==> Rebuilding squashfs..."
rm -f "$SQUASH"
mksquashfs "$EDIT" "$SQUASH" -comp xz -b 1M -Xdict-size 100%

echo "==> Updating size file if present..."
if [[ -f "$SQUASH_DIR/filesystem.size" ]]; then
  printf '%s' "$(du -sx --block-size=1 "$EDIT" | cut -f1)" >"$SQUASH_DIR/filesystem.size"
fi

# Regenerate md5sum.txt excluding itself
if [[ -f "$EXTRACT/md5sum.txt" ]]; then
  echo "==> Regenerating md5sum.txt..."
  (cd "$EXTRACT" && find . -type f -not -name md5sum.txt -print0 | xargs -0 md5sum >md5sum.txt)
fi

echo "==> Building hybrid ISO with xorriso..."
# Detect EFI/boot layout common on Ubuntu
BOOT_OPTS=()
if [[ -d "$EXTRACT/boot/grub" ]]; then
  # Ubuntu-style
  if [[ -f "$EXTRACT/boot/grub/i386-pc/eltorito.img" ]] || [[ -f "$EXTRACT/isolinux/isolinux.bin" ]]; then
    :
  fi
fi

# Generic Ubuntu live ISO rebuild
xorriso -as mkisofs \
  -r -V "UST Tablet 26.04" \
  -o "$OUT_ISO" \
  -J -joliet-long -l \
  -iso-level 3 \
  -partition_offset 16 \
  --grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"$SRC_ISO" \
  -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:0s-0s:zero_mbrpt:"$SRC_ISO" \
  -appended_part_as_gpt \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
  -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:all::' \
  -no-emul-boot \
  "$EXTRACT" 2>/tmp/ust-xorriso.log || {
    echo "Primary xorriso recipe failed; trying simpler copy-isohybrid approach..."
    cat /tmp/ust-xorriso.log || true
    # Fallback: extract boot image method
    xorriso -indev "$SRC_ISO" -outdev "$OUT_ISO" \
      -boot_image any replay \
      -map "$EXTRACT" / \
      -chmod 0755 / -- 2>/tmp/ust-xorriso2.log || {
        echo "Remaster ISO packing failed. Squashfs was updated at: $SQUASH" >&2
        echo "See /tmp/ust-xorriso*.log — you can also use CUBIC GUI on the edited tree." >&2
        exit 1
      }
  }

echo "==> Output: $OUT_ISO"
ls -lh "$OUT_ISO"
echo "Write to USB: sudo dd if=$OUT_ISO of=/dev/sdX bs=4M status=progress oflag=sync"
