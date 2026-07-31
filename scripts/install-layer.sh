#!/usr/bin/env bash
# Portable layer install: configs + apps + launchers (no distro shell install)
# Works on Ubuntu arm64/amd64, postmarketOS, Mobian — any Plasma 6 host.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/scripts/lib/common.sh"
UST_ROOT="$ROOT"

ust_require_root

PREFIX="${PREFIX:-/usr}"
LIBDIR="$PREFIX/lib/ubuntu-studio-tablet"
SHARE="$PREFIX/share/ubuntu-studio-tablet"
APPDIR="$PREFIX/share/applications"
AUTOSTART="/etc/xdg/autostart"
SKEL="/etc/skel"
MODE="${1:-auto}"   # auto|desktop|mobile

if [[ "$MODE" == "auto" ]]; then
  case "$(ust_plasma_variant)" in
    plasma-mobile|plasma-mobile-available) MODE=mobile ;;
    *) MODE=desktop ;;
  esac
fi

ust_log "Ubuntu Studio Tablet — portable layer ($MODE)"
ust_detect_report
echo ""

# --- binaries ---
ust_log "Installing launchers → $LIBDIR/bin"
mkdir -p "$LIBDIR/bin" "$SHARE/wallpapers" "$SHARE/desktop" "$SHARE/plasma-mobile"
install -m 0755 "$ROOT/scripts/ust-launch" "$LIBDIR/bin/ust-launch"
install -m 0755 "$ROOT/scripts/ust-session-init" "$LIBDIR/bin/ust-session-init"
install -m 0755 "$ROOT/scripts/ust-home-launcher" "$LIBDIR/bin/ust-home-launcher"
install -m 0755 "$ROOT/scripts/ust-start-session" "$LIBDIR/bin/ust-start-session"
if [[ -f "$ROOT/scripts/ust-start-plasma-mobile" ]]; then
  install -m 0755 "$ROOT/scripts/ust-start-plasma-mobile" "$LIBDIR/bin/ust-start-plasma-mobile"
fi
if [[ -f "$ROOT/scripts/ust-waydroid" ]]; then
  install -m 0755 "$ROOT/scripts/ust-waydroid" "$LIBDIR/bin/ust-waydroid"
fi

# --- desktop files ---
ust_log "Generating app-style .desktop entries"
bash "$ROOT/scripts/generate-app-desktops.sh" "$SHARE/desktop"
# Prefer apps that exist on this machine (optional soft filter)
if [[ -x "$ROOT/scripts/filter-desktop-by-binary.sh" ]]; then
  bash "$ROOT/scripts/filter-desktop-by-binary.sh" "$SHARE/desktop" || true
fi
install -m 0644 "$SHARE/desktop"/*.desktop "$APPDIR/" 2>/dev/null || true
mkdir -p "$ROOT/apps/desktop"
cp -a "$SHARE/desktop"/*.desktop "$ROOT/apps/desktop/" 2>/dev/null || true

# Waydroid helper desktop if present
if [[ -f "$ROOT/apps/desktop-extra/ust-waydroid.desktop" ]]; then
  install -m 0644 "$ROOT/apps/desktop-extra/ust-waydroid.desktop" "$APPDIR/"
fi

# --- plasma configs ---
install_cfg() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  install -m 0644 "$src" "$dest"
}

CFG_DIR="$ROOT/configs/plasma"
if [[ "$MODE" == mobile && -d "$ROOT/configs/plasma-mobile" ]]; then
  ust_log "Using Plasma Mobile config set"
  # Mobile overlays desktop configs where files exist
  CFG_DIR="$ROOT/configs/plasma"
fi

ust_log "Installing Plasma configs → skel + homes"
for f in kwinrc kwinrulesrc plasmarc kdeglobals kcminputrc kxkbrc; do
  [[ -f "$CFG_DIR/$f" ]] || continue
  install_cfg "$CFG_DIR/$f" "$SKEL/.config/$f"
done

if [[ "$MODE" == mobile ]]; then
  for f in "$ROOT/configs/plasma-mobile/"*; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f")
    install_cfg "$f" "$SKEL/.config/$base"
  done
  # Keep kwin rules from main plasma set (fullscreen studio apps)
  [[ -f "$ROOT/configs/plasma/kwinrulesrc" ]] && \
    install_cfg "$ROOT/configs/plasma/kwinrulesrc" "$SKEL/.config/kwinrulesrc"
else
  if [[ -f "$ROOT/configs/plasma/plasma-org.kde.plasma.desktop-appletsrc" ]]; then
    install_cfg "$ROOT/configs/plasma/plasma-org.kde.plasma.desktop-appletsrc" \
      "$SKEL/.config/plasma-org.kde.plasma.desktop-appletsrc"
  fi
fi

install -m 0644 "$ROOT/configs/autostart/ust-tablet-session.desktop" \
  "$AUTOSTART/ust-tablet-session.desktop"

# Apply to existing users
for home in /home/*; do
  [[ -d "$home" ]] || continue
  user=$(basename "$home")
  id "$user" >/dev/null 2>&1 || continue
  # postmarketOS default user
  ust_log "Configuring user: $user"
  mkdir -p "$home/.config" "$home/.config/autostart" "$home/.local/share/applications"
  for f in kwinrc kwinrulesrc plasmarc kdeglobals kcminputrc kxkbrc; do
    src="$SKEL/.config/$f"
    [[ -f "$src" ]] || continue
    if [[ -f "$home/.config/$f" ]]; then
      cp -a "$home/.config/$f" "$home/.config/${f}.pre-ust.bak" 2>/dev/null || true
    fi
    install -o "$user" -g "$user" -m 0644 "$src" "$home/.config/$f"
  done
  if [[ "$MODE" == mobile ]]; then
    for f in "$ROOT/configs/plasma-mobile/"*; do
      [[ -f "$f" ]] || continue
      base=$(basename "$f")
      install -o "$user" -g "$user" -m 0644 "$f" "$home/.config/$base"
    done
  fi
  install -o "$user" -g "$user" -m 0644 \
    "$ROOT/configs/autostart/ust-tablet-session.desktop" \
    "$home/.config/autostart/ust-tablet-session.desktop"
  install -o "$user" -g "$user" -m 0644 \
    "$SHARE/desktop"/*.desktop "$home/.local/share/applications/" 2>/dev/null || true
done

# Branding
if [[ -f "$ROOT/branding/studio-tablet-dark.svg" ]]; then
  install -m 0644 "$ROOT/branding/studio-tablet-dark.svg" "$SHARE/wallpapers/"
fi
if [[ -f "$ROOT/branding/studio-tablet-dark.png" ]]; then
  install -m 0644 "$ROOT/branding/studio-tablet-dark.png" "$SHARE/wallpapers/"
fi

# Environment
mkdir -p /etc/environment.d
cat >/etc/environment.d/90-ubuntu-studio-tablet.conf <<'EOF'
# Ubuntu Studio Tablet (ARM / desktop / mobile)
QT_QUICK_CONTROLS_MOBILE=1
# High-DPI tablets (adjust as needed):
# QT_SCALE_FACTOR=1.25
# GDK_SCALE=2
EOF

if [[ "$MODE" == mobile ]]; then
  cat >/etc/environment.d/91-ubuntu-studio-tablet-mobile.conf <<'EOF'
QT_QUICK_CONTROLS_MOBILE=1
PLASMA_PLATFORM=phone:handheld
# Hint for Kirigami apps
QT_QUICK_CONTROLS_STYLE=org.kde.breeze
EOF
fi

# Sessions
mkdir -p /usr/share/wayland-sessions /usr/share/xsessions
if [[ "$MODE" == mobile ]]; then
  cat >/usr/share/wayland-sessions/ubuntu-studio-tablet.desktop <<'EOF'
[Desktop Entry]
Type=Application
DesktopNames=KDE
Name=Ubuntu Studio Tablet (Plasma Mobile)
Name[zh_CN]=Ubuntu Studio 平板 (Plasma Mobile)
Comment=ARM tablet session — Studio apps as native fullscreen apps
Comment[zh_CN]=ARM 平板会话 · 创作应用全屏原生风格
Exec=/usr/lib/ubuntu-studio-tablet/bin/ust-start-plasma-mobile
TryExec=/usr/lib/ubuntu-studio-tablet/bin/ust-start-plasma-mobile
EOF
else
  cat >/usr/share/wayland-sessions/ubuntu-studio-tablet.desktop <<'EOF'
[Desktop Entry]
Type=Application
DesktopNames=KDE
Name=Ubuntu Studio Tablet
Name[zh_CN]=Ubuntu Studio 平板
Comment=Tablet-first Plasma with app-style fullscreen Studio apps
Exec=/usr/lib/ubuntu-studio-tablet/bin/ust-start-session
TryExec=/usr/bin/startplasma-wayland
EOF
fi

if command -v update-desktop-database >/dev/null; then
  update-desktop-database /usr/share/applications || true
fi

ust_log "Layer install complete (mode=$MODE)."
echo "    Launchers: $LIBDIR/bin"
echo "    Apps:      $APPDIR/ust-*.desktop"
echo "    Session:   Ubuntu Studio Tablet (login screen)"
