#!/usr/bin/env bash
# Print pmbootstrap init / flash hints for a codename from our matrix.
# Does NOT unlock bootloaders or flash devices.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MATRIX="$ROOT/data/device-matrix.tsv"
CODE="${1:-}"

if [[ -z "$CODE" || "$CODE" == "-h" || "$CODE" == "--help" ]]; then
  cat <<EOF
Usage: $0 <codename>

Example:
  $0 lenovo-j716f

This only prints guidance. Flashing can brick devices — follow the
postmarketOS device wiki, not this script, for unlock/flash steps.
EOF
  exit 0
fi

row=$(awk -F'\t' -v k="$CODE" '/^#/||NF<6{next} $1==k{print; exit}' "$MATRIX" || true)
if [[ -z "$row" ]]; then
  echo "Unknown codename: $CODE"
  echo "Run: ./scripts/check-device-support.sh --codename $CODE"
  echo "Or list matrix: grep -v '^#' $MATRIX | cut -f1"
  exit 1
fi

names=$(echo "$row" | cut -f2)
soc=$(echo "$row" | cut -f3)
status=$(echo "$row" | cut -f5)
notes=$(echo "$row" | cut -f6)
wiki=$(echo "$row" | cut -f7)

vendor="lenovo"
device="$CODE"
if [[ "$CODE" == lenovo-* ]]; then
  device="${CODE#lenovo-}"
elif [[ "$CODE" == pine64-* ]]; then
  vendor="pine64"
  device="${CODE#pine64-}"
elif [[ "$CODE" == google-* ]]; then
  vendor="google"
  device="${CODE#google-}"
elif [[ "$CODE" == generic-* ]]; then
  echo "=== $CODE is a SoC family placeholder, not a flashable device ==="
  echo "$notes"
  echo "You must create or find a real device package first (docs/ARM-PORT.md Path E)."
  exit 3
fi

cat <<EOF
=== pmbootstrap hints for $CODE ===
Marketing : $names
SoC       : $soc
Status    : $status
Notes     : $notes
Wiki      : https://wiki.postmarketos.org/wiki/${wiki:--}

IMPORTANT
---------
* This script does NOT unlock, flash, or wipe anything.
* Unlocking often erases user data and may be irreversible.
* Keep stock firmware before any flash.
* If status is archived/unsupported, stop and read docs/ARM-PORT.md.

1) Install pmbootstrap on a Linux PC
   pipx install pmbootstrap
   # or: sudo apt install pmbootstrap   # if packaged

2) Initialize (interactive)
   pmbootstrap init
     Work path     : ~/._pmbootstrap   (default is fine)
     Channel       : edge or stable (see wiki)
     Vendor        : $vendor
     Device        : $device
     UI            : plasma-mobile
     Extra packages: (none required; Studio layer installs later)
     User          : choose username
     Hostname      : studio-tablet

3) Build rootfs
   pmbootstrap install

4) Flash — ONLY methods from the device wiki
   Typical patterns (VERIFY ON WIKI):
     pmbootstrap flasher flash_kernel
     pmbootstrap flasher flash_rootfs
     # or: pmbootstrap export  +  fastboot flash ...
     # or: sdcard install for some tablets

5) Boot Plasma Mobile, get network + ssh/terminal

6) Install Ubuntu Studio Tablet layer
   # copy this repo onto the device, then:
   sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid

Status-specific advice: $status
EOF

case "$status" in
  archived)
    cat <<EOF

ARCHIVED DEVICE
  Expect missing packages, broken display, or unmaintained kernel.
  Check if codename still appears in: pmbootstrap init → device list.
  If missing, the port is gone from tree — Path C/D in docs/ARM-PORT.md.
EOF
    ;;
  testing_unmerged)
    cat <<EOF

TESTING / UNMERGED
  Device may need a custom aports branch or MR not in official repos.
  Search GitLab postmarketOS/pmaports for: $device
EOF
    ;;
  unsupported)
    cat <<EOF

UNSUPPORTED
  No flash path. Use docs/ARM-PORT.md Path C or D.
EOF
    exit 3
    ;;
esac
