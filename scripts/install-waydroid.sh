#!/usr/bin/env bash
# Install and configure Waydroid for Android apps alongside Studio Tablet
# Best on ARM64 devices with working binder / binderfs (kernel support required).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"
ust_require_root

ust_log "Waydroid setup for Ubuntu Studio Tablet"
ust_detect_report

PM="$(ust_pkg_manager)"

install_waydroid_apt() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y || true
  # Official packages where available
  if apt-cache show waydroid >/dev/null 2>&1; then
    apt-get install -y waydroid python3-pip lxc curl ca-certificates \
      || ust_warn "waydroid apt install partial"
  else
    ust_warn "waydroid not in apt — adding remote instructions"
    # Try common Ubuntu method via libgbinder deps
    apt-get install -y curl ca-certificates python3-pip lxc || true
    if [[ ! -f /usr/bin/waydroid ]]; then
      cat <<'TIP'
Waydroid package missing from this Ubuntu suite.

Manual options:
  1) https://docs.waydro.id/usage/install-on-desktops
  2) For Ubuntu:
       sudo apt install curl ca-certificates -y
       curl -s https://repo.waydro.id | sudo bash
       sudo apt install waydroid -y
  3) Then re-run: sudo ./scripts/install-waydroid.sh
TIP
      return 1
    fi
  fi
}

install_waydroid_apk() {
  # postmarketOS / Alpine
  apk update || true
  apk add waydroid waydroid-openrc 2>/dev/null \
    || apk add waydroid 2>/dev/null \
    || {
      ust_warn "waydroid not in apk repos for this channel"
      return 1
    }
  # binder modules sometimes separate
  apk add linux-edge 2>/dev/null || true
}

case "$PM" in
  apt) install_waydroid_apt || true ;;
  apk) install_waydroid_apk || true ;;
  *) ust_die "No supported package manager" ;;
esac

if ! command -v waydroid >/dev/null 2>&1; then
  ust_warn "waydroid binary not available yet — see docs/WAYDROID.md"
  # still install helper + desktop
else
  ust_log "Initializing Waydroid images (may download ~1GB)..."
  # Non-interactive init if already done is fine
  if [[ ! -d /var/lib/waydroid/images ]] && [[ ! -f /var/lib/waydroid/waydroid.cfg ]]; then
    waydroid init -s GAPPS -f || waydroid init -f || waydroid init || ust_warn "waydroid init failed (network/kernel?)"
  else
    ust_log "Waydroid already initialized"
  fi

  # Container service
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now waydroid-container.service 2>/dev/null \
      || systemctl enable --now waydroid-container 2>/dev/null \
      || ust_warn "Could not enable waydroid-container service"
  fi
fi

# Install wrapper + desktop
install -m 0755 "$ROOT/scripts/ust-waydroid" /usr/lib/ubuntu-studio-tablet/bin/ust-waydroid
mkdir -p /usr/share/applications
install -m 0644 "$ROOT/apps/desktop-extra/ust-waydroid.desktop" /usr/share/applications/ 2>/dev/null \
  || cat >/usr/share/applications/ust-waydroid.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Android Apps
Name[zh_CN]=安卓应用 (Waydroid)
Comment=Launch Waydroid full UI — Android apps on Linux
Comment[zh_CN]=在 Linux 上运行安卓应用
Exec=/usr/lib/ubuntu-studio-tablet/bin/ust-waydroid ui
Icon=android-sdk
Terminal=false
Categories=UbuntuStudioTablet;Utility;
X-Ubuntu-Studio-Tablet=true
X-KDE-FormFactor=tablet;handset;desktop;
EOF

# Prop tweaks for multi-window / tablet-ish Android (best-effort)
if command -v waydroid >/dev/null 2>&1; then
  waydroid prop set persist.waydroid.multi_windows true 2>/dev/null || true
  waydroid prop set persist.waydroid.cursor_on_subsurface true 2>/dev/null || true
fi

ust_log "Waydroid integration installed."
echo "    Start UI:  ust-waydroid ui"
echo "    App list:  waydroid app list"
echo "    Docs:      $ROOT/docs/WAYDROID.md"
echo ""
echo "Kernel note: binder / ashmem must be available. On many mainline"
echo "tablets you need a kernel with CONFIG_ANDROID_BINDERFS=y."
