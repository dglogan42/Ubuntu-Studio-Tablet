#!/usr/bin/env bash
# Chinese locale, fonts, fcitx5 Pinyin — optimized for CN tablet users
set -euo pipefail

if [[ "${EUID:-}" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y \
  language-pack-zh-hans \
  language-pack-kde-zh-hans \
  fonts-noto-cjk \
  fonts-wqy-zenhei \
  fonts-wqy-microhei \
  fcitx5 \
  fcitx5-chinese-addons \
  fcitx5-frontend-gtk3 \
  fcitx5-frontend-gtk4 \
  fcitx5-config-qt \
  fcitx5-module-cloudpinyin \
  kde-config-fcitx5 \
  locales || true

# Locales
sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LANGUAGE=zh_CN:zh:en

# System-wide IM environment
cat >/etc/environment.d/99-ubuntu-studio-tablet-im.conf <<'EOF'
GTK_IM_MODULE=fcitx5
QT_IM_MODULE=fcitx5
XMODIFIERS=@im=fcitx5
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

# Default fcitx5 profile for skel / new users
SKEL_FCITX="/etc/skel/.config/fcitx5"
mkdir -p "$SKEL_FCITX/conf"
cat >"$SKEL_FCITX/profile" <<'EOF'
[Groups/0]
# Group Name
Name=默认
# Layout
Default Layout=us
# Default Input Method
DefaultIM=pinyin

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=pinyin
# Layout
Layout=

[GroupOrder]
0=默认
EOF

cat >"$SKEL_FCITX/config" <<'EOF'
[Hotkey]
# Trigger Input Method
TriggerKeys=Control+space Control+Shift_L

[Behavior]
# Share Input State
ShareInputState=All
# Show input method information when changing input method
ShowInputMethodInformation=True
EOF

echo "Chinese setup complete."
echo "Log out and back in. Toggle IME with Ctrl+Space."
echo "Optional: use a China mirror — see docs/XIAOXIN.md"
