#!/usr/bin/env bash
# Fallbacks when there is NO working native ARM Linux port.
# Prints copy-paste guides; does not modify the tablet.
set -euo pipefail

MODE="${1:---print-all}"

termux() {
  cat <<'EOF'
=== Path C1 — Termux + proot (Android stays, no bootloader unlock) ===

Termux is a powerful Android terminal that runs a Linux CLI and packages
directly on the tablet (prefer F-Droid builds).

On the tablet:
  1. Install Termux (prefer F-Droid build)
  2. Install Termux:X11 if you want a nested GUI

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

andronix() {
  cat <<'EOF'
=== Path C1b — Andronix (Linux desktop envs on top of Android) ===

Andronix installs full Linux desktop environments (XFCE, LXQt, …) on top
of your existing Android system, usually with Termux + proot-style rootfs.

  1. Install Andronix from the Play Store / their site
  2. Pick a distro + DE (e.g. Ubuntu + XFCE)
  3. Follow their Termux commands; start VNC/Termux:X11 as directed

Good for: trying a Linux desktop without wiping Android.
Weak for: real-time audio, GPU-heavy video, "native tablet OS" feel.
Not a substitute for amd64 Ubuntu Studio or install-tablet-mode.sh.

See also: docs/ANDROID-ALTERNATIVES.md
EOF
}

mobile_os() {
  cat <<'EOF'
=== Path B — Replace Android (supported hardware only) ===

Ubuntu Touch:
  Mobile-friendly Ubuntu that replaces Android on supported phones/tablets.
  https://ubuntu-touch.io/  — check device support first.
  Not the same as Ubuntu Studio desktop.

postmarketOS:
  Alpine-based, touch-friendly mobile Linux.
  https://wiki.postmarketos.org/wiki/Devices
  Prefer Plasma Mobile UI when available, then:
    sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative

Neither path is "flash the Ubuntu Studio amd64 ISO on the pad."
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
  cat <<'EOF'
NOTE: Full Ubuntu Studio desktop is NOT natively supported on Android tablets.
See docs/ANDROID-ALTERNATIVES.md for the full comparison.

EOF
  mobile_os
  echo ""
  termux
  echo ""
  andronix
  echo ""
  remote
  echo ""
  chroot_root
  cat <<'EOF'

=== Next tools in this repo ===
  ./scripts/check-device-support.sh --adb
  docs/ANDROID-ALTERNATIVES.md
  docs/ARM-PORT.md
  docs/XIAOXIN.md

Native layer (only after real Linux boots):
  sudo ./scripts/install-arm.sh --ui plasma-mobile
EOF
}

case "$MODE" in
  --print-termux|--termux) termux ;;
  --print-andronix|--andronix) andronix ;;
  --print-mobile-os|--mobile-os) mobile_os ;;
  --print-remote|--remote) remote ;;
  --print-chroot|--chroot) chroot_root ;;
  --print-all|-h|--help)
    if [[ "$MODE" == "-h" || "$MODE" == "--help" ]]; then
      echo "Usage: $0 --print-all|--print-termux|--print-andronix|--print-mobile-os|--print-remote|--print-chroot"
      exit 0
    fi
    all
    ;;
  *)
    echo "Usage: $0 --print-all|--print-termux|--print-andronix|--print-mobile-os|--print-remote|--print-chroot" >&2
    exit 1
    ;;
esac
