#!/usr/bin/env bash
# Install Ubuntu Studio Tablet on AMD64 Ubuntu Studio / Plasma Desktop
# For ARM / Plasma Mobile use: install-arm.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"
ust_require_root

if ust_is_arm; then
  ust_warn "Detected ARM ($(ust_arch)). Prefer: sudo $ROOT/scripts/install-arm.sh"
  ust_warn "Continuing with desktop tablet packages + layer..."
fi

ust_log "Ubuntu Studio Tablet installer (desktop / AMD64 path)"
ust_detect_report
echo ""

export DEBIAN_FRONTEND=noninteractive
case "$(ust_pkg_manager)" in
  apt)
    ust_install_apt_list "$ROOT/packages/tablet-packages.list"
    ;;
  apk)
    ust_install_apk_list "$ROOT/packages/plasma-desktop-apk.list"
    ;;
  *)
    ust_warn "No apt/apk — installing layer only"
    ;;
esac

# Portable configs + apps (desktop mode)
bash "$ROOT/scripts/install-layer.sh" desktop

# SDDM touch cursor (desktop installs)
mkdir -p /etc/sddm.conf.d
cat >/etc/sddm.conf.d/ubuntu-studio-tablet.conf <<'EOF'
[Theme]
CursorSize=36
EOF

# X11 fallback session
mkdir -p /usr/share/xsessions
cat >/usr/share/xsessions/ubuntu-studio-tablet.desktop <<'EOF'
[Desktop Entry]
Type=Application
DesktopNames=KDE
Name=Ubuntu Studio Tablet (X11)
Name[zh_CN]=Ubuntu Studio 平板 (X11)
Comment=Tablet-first Ubuntu Studio (X11)
Exec=/usr/lib/ubuntu-studio-tablet/bin/ust-start-session --x11
TryExec=/usr/bin/startplasma-x11
EOF

mkdir -p /usr/share/desktop-directories
cat >/usr/share/desktop-directories/ust-tablet.directory <<'EOF'
[Desktop Entry]
Name=Studio Tablet Apps
Name[zh_CN]=平板创作应用
Icon=preferences-desktop-display
Type=Directory
EOF

echo ""
ust_log "Install complete (desktop tablet mode)."
echo "    ARM devices: sudo $ROOT/scripts/install-arm.sh --ui plasma-mobile"
echo "    Chinese:     sudo $ROOT/scripts/setup-chinese.sh"
echo "    Log out → session: Ubuntu Studio Tablet"
echo ""
