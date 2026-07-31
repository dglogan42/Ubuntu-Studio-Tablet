#!/usr/bin/env bash
# Fallbacks when there is NO working native ARM Linux port.
# Prints copy-paste guides; does not modify the tablet.
set -euo pipefail

MODE="${1:---print-all}"

termux() {
  cat <<'EOF'
=== Path C1 — Termux + proot (Android stays, no bootloader unlock) ===

On the tablet (F-Droid or Play):
  1. Install Termux (prefer F-Droid build)
  2. Install Termux:X11 if you want a GUI

In Termux:
  pkg update && pkg upgrade
  pkg install proot-distro
  proot-distro install ubuntu
  proot-distro login ubuntu

Inside Ubuntu proot:
  apt update
  apt install -y sudo nano
  # CLI creative tools may work; full Plasma Mobile will NOT
  # (no real KMS/DRM session inside proot)

What you can do:
  - compile, scripts, light CLI audio tools
  - ssh to a real Studio host
What you cannot do:
  - native Plasma Mobile as device UI
  - install-arm.sh as a daily driver shell
  - low-latency DAW with hardware RT guarantees

Studio Tablet repo: use only individual tools or remote workflow.
EOF
}

remote() {
  cat <<'EOF'
=== Path C2 — Xiaoxin as glass, AMD64 as Studio (recommended) ===

On the PC (x86_64):
  1. Install Ubuntu Studio 26.04
  2. cd ubuntu-studio-tablet && sudo ./scripts/install-tablet-mode.sh
  3. Install a remote stack, e.g.:
       sudo apt install sunshine
       # or: gnome-remote-desktop / xrdp / krdc server side

On the Xiaoxin (Android):
  - Moonlight (for Sunshine)
  - Microsoft Remote Desktop / Scrcpy for control
  - KDE Connect for clipboard/files

Network: same LAN, wired PC preferred for audio/video.

Result: full Studio apps with tablet as touch/display client.
        No ARM port required.
EOF
}

chroot_root() {
  cat <<'EOF'
=== Path C3 — Linux Deploy / chroot (needs root on Android) ===

Requires unlocked bootloader + Magisk (or similar) — still not a
mainline port; shares Android kernel.

  1. Unlock + root following device-specific guides (risk of brick)
  2. Linux Deploy or similar → Ubuntu arm64 chroot
  3. Start multiuser + VNC/X2Go
  4. Optional: attempt Plasma in chroot (heavy, often janky)

Compared to proot: better filesystem access, still no proper
device session. Prefer Path C2 for creative work.
EOF
}

all() {
  termux
  echo ""
  remote
  echo ""
  chroot_root
  cat <<'EOF'

=== Next tools in this repo ===
  ./scripts/check-device-support.sh --adb
  docs/ARM-PORT.md
  docs/XIAOXIN.md

Native layer (only after real Linux boots):
  sudo ./scripts/install-arm.sh --ui plasma-mobile
EOF
}

case "$MODE" in
  --print-termux) termux ;;
  --print-remote) remote ;;
  --print-chroot) chroot_root ;;
  --print-all|-h|--help)
    if [[ "$MODE" == "-h" || "$MODE" == "--help" ]]; then
      echo "Usage: $0 --print-all|--print-termux|--print-remote|--print-chroot"
      exit 0
    fi
    all
    ;;
  *)
    echo "Usage: $0 --print-all|--print-termux|--print-remote|--print-chroot" >&2
    exit 1
    ;;
esac
