#!/usr/bin/env bash
# Generate tablet-style .desktop files for Ubuntu Studio apps
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/apps/desktop}"
mkdir -p "$OUT"

# name|zh|exec|icon|class|categories
APPS=(
  "Krita|Krita 数字绘画|krita|krita|krita|Graphics;2DGraphics;"
  "GIMP|GIMP 图像编辑|gimp|gimp|Gimp|Graphics;2DGraphics;"
  "Inkscape|Inkscape 矢量|inkscape|org.inkscape.Inkscape|org.inkscape.Inkscape|Graphics;VectorGraphics;"
  "Darktable|Darktable 摄影|darktable|darktable|darktable|Graphics;Photography;"
  "RawTherapee|RawTherapee|rawtherapee|rawtherapee|rawtherapee|Graphics;Photography;"
  "Blender|Blender 3D|blender|blender|Blender|Graphics;3DGraphics;"
  "Ardour|Ardour 数字音频工作站|ardour|ardour|Ardour|AudioVideo;Audio;"
  "Audacity|Audacity 录音编辑|audacity|audacity|Audacity|AudioVideo;Audio;"
  "Qtractor|Qtractor|qtractor|qtractor|qtractor|AudioVideo;Audio;"
  "Carla|Carla 插件主机|carla|carla|carla2|AudioVideo;Audio;"
  "Hydrogen|Hydrogen 鼓机|hydrogen|hydrogen|hydrogen|AudioVideo;Audio;"
  "LMMS|LMMS 编曲|lmms|lmms|lmms|AudioVideo;Audio;"
  "Mixxx|Mixxx DJ|mixxx|mixxx|mixxx|AudioVideo;Audio;"
  "PipeWire Graph|音频连线|qpwgraph|qpwgraph|qpwgraph|AudioVideo;Audio;"
  "Kdenlive|Kdenlive 视频剪辑|kdenlive|kdenlive|kdenlive|AudioVideo;Video;"
  "OBS Studio|OBS 直播推流|obs|com.obsproject.Studio|obs|AudioVideo;Video;"
  "Shotcut|Shotcut 视频|shotcut|org.shotcut.Shotcut|shotcut|AudioVideo;Video;"
  "digiKam|digiKam 相册|digikam|digikam|digikam|Graphics;Photography;"
  "Gwenview|看图|gwenview|gwenview|org.kde.gwenview|Graphics;Viewer;"
  "Okular|文档阅读|okular|okular|org.kde.okular|Office;Viewer;"
  "Files|文件|dolphin|system-file-manager|org.kde.dolphin|System;FileManager;"
  "Settings|系统设置|systemsettings|preferences-system|systemsettings|Settings;"
  "Discover|软件商店|plasma-discover|plasmadiscover|plasma-discover|PackageManager;"
  "Browser|浏览器|firefox|firefox|Navigator|Network;WebBrowser;"
  "Terminal|终端|konsole|utilities-terminal|konsole|System;TerminalEmulator;"
  "Elisa|音乐|elisa|elisa|org.kde.elisa|AudioVideo;Player;"
  "Calculator|计算器|kalk|accessories-calculator|org.kde.kalk|Utility;"
  "Clock|时钟|kclock|preferences-system-time|org.kde.kclock|Utility;"
)

for entry in "${APPS[@]}"; do
  IFS='|' read -r name zh exec icon class cats <<<"$entry"
  id="ust-$(echo "$exec" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9+-')"
  file="$OUT/${id}.desktop"
  cat >"$file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${name}
Name[zh_CN]=${zh}
GenericName=Tablet App
GenericName[zh_CN]=平板应用
Comment=Ubuntu Studio Tablet fullscreen app
Comment[zh_CN]=Ubuntu Studio 平板全屏应用
Exec=/usr/lib/ubuntu-studio-tablet/bin/ust-launch --class ${class} -- ${exec}
Icon=${icon}
Terminal=false
StartupNotify=true
StartupWMClass=${class}
Categories=UbuntuStudioTablet;${cats}
Keywords=studio;tablet;touch;${name};
X-Ubuntu-Studio-Tablet=true
X-KDE-FormFactor=tablet;handset;desktop;
EOF
  echo "Wrote $file"
done

echo "Generated ${#APPS[@]} desktop entries in $OUT"
