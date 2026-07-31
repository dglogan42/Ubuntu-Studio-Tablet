# Ubuntu Studio Tablet (UST)

Tablet-first configuration layer for **Ubuntu Studio 26.04 LTS** (“Resolute Raccoon”) and other **Plasma 6** systems.

Creative apps (Krita, GIMP, Ardour, Audacity, Kdenlive, …) launch like **native Android / iOS apps**: full screen, large touch targets, Chinese + English labels, on-screen keyboard.

| | |
|--|--|
| **Base ISO (amd64)** | [ubuntustudio-26.04-desktop-amd64.iso](https://cdimage.ubuntu.com/ubuntustudio/releases/resolute/release/) |
| **License** | [MIT](LICENSE) (this repo only; upstream apps keep their own licenses) |
| **Status** | Scripts + configs; not an official Ubuntu flavor |

---

## Features

- **App-style launchers** — `ust-launch` + KWin rules maximize Studio apps without desktop chrome clutter  
- **Plasma tablet / Plasma Mobile** — desktop tablet mode (x86) or mobile shell (ARM)  
- **Chinese-first** — `zh_CN`, Noto CJK fonts, fcitx5 Pinyin (`setup-chinese.sh`)  
- **Xiaoxin guides** — laptop dual-boot (BitLocker, Fast Startup, shrink) and Pad/ARM port paths  
- **Waydroid helpers** — optional Android apps on a working Linux ARM/x86 host  
- **ISO remaster hooks** — optional rebuild of a live image (amd64, lots of free disk)

---

## Device compatibility

| Device | Arch | Use this repo how? |
|--------|------|---------------------|
| **Lenovo Xiaoxin Pro laptop** / Yoga 2-in-1 | **AMD64** | Install Ubuntu Studio from USB → `install-tablet-mode.sh` |
| x86 mini-PC / Intel tablet PC | **AMD64** | Same |
| **Xiaoxin Pad Pro** (most models) | **ARM64** | Need a working Linux port first → then `install-arm.sh` |
| postmarketOS / Ubuntu arm64 / Mobian | **ARM64** | `install-arm.sh --ui plasma-mobile` |

This repo **does not** unlock bootloaders or ship device kernels.

### Android tablets (important)

**Running Ubuntu Studio directly on an Android tablet is not natively supported.** The official Studio ISO is **amd64** desktop Linux; typical pads stay on **Android / ARM64**.

| If you want… | Use |
|--------------|-----|
| Full Studio apps + tablet UX | AMD64 PC/laptop + this layer (or remote into it from the pad) |
| Replace Android entirely | **Ubuntu Touch** or **postmarketOS** *only on supported devices*, then optionally `install-arm.sh` |
| Linux *without* wiping Android | **Andronix** (XFCE/LXQt on Termux) or **Termux** CLI / proot |

Full write-up: **[docs/ANDROID-ALTERNATIVES.md](docs/ANDROID-ALTERNATIVES.md)** · bridge cheat sheet: `./scripts/android-linux-bridge.sh --print-all`

---

## Quick start

### Xiaoxin Pro laptop / AMD64 (recommended)

1. Install Ubuntu (dual-boot checklist + BIOS): **[docs/XIAOXIN-LAPTOP.md](docs/XIAOXIN-LAPTOP.md)**  
2. Prefer Ubuntu Studio 26.04 amd64, then:

```bash
cd ubuntu-studio-tablet
chmod +x scripts/*.sh scripts/ust-* scripts/lib/*.sh
sudo ./scripts/install-tablet-mode.sh
sudo ./scripts/setup-chinese.sh          # optional
# Log out → session: Ubuntu Studio Tablet
```

### ARM tablet (after Linux already boots)

```bash
./scripts/check-device-support.sh --adb  # still on Android, optional
# After Plasma Mobile boots on device:
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

Port guide: **[docs/ARM-PORT.md](docs/ARM-PORT.md)**

### Layer only (any Plasma 6)

```bash
sudo ./scripts/install-layer.sh mobile   # or: desktop
```

### Preview home grid (browser)

```bash
xdg-open apps/home-grid.html
# or: make preview
```

### Validate the tree

```bash
./scripts/validate.sh
# or: make validate
```

---

## Documentation

| Doc | Topic |
|-----|--------|
| [docs/INSTALL.md](docs/INSTALL.md) | Install options |
| [docs/ANDROID-ALTERNATIVES.md](docs/ANDROID-ALTERNATIVES.md) | **Why Studio ≠ Android pad** — Ubuntu Touch, pmOS, Andronix, Termux |
| [docs/XIAOXIN-LAPTOP.md](docs/XIAOXIN-LAPTOP.md) | Xiaoxin Pro laptop: USB, BIOS, **dual-boot Windows** |
| [docs/XIAOXIN.md](docs/XIAOXIN.md) | Laptop vs Pad overview |
| [docs/ARM-PORT.md](docs/ARM-PORT.md) | Get ARM Linux booting first |
| [docs/ARM.md](docs/ARM.md) | ARM layer after boot |
| [docs/PLASMA-MOBILE.md](docs/PLASMA-MOBILE.md) | Plasma Mobile session |
| [docs/WAYDROID.md](docs/WAYDROID.md) | Android apps on Linux |
| [docs/UX-DESIGN.md](docs/UX-DESIGN.md) | UX principles |

---

## Project layout

```
ubuntu-studio-tablet/
├── README.md
├── LICENSE
├── .gitignore
├── Makefile
├── apps/
│   ├── desktop/              # generated ust-*.desktop (Studio apps)
│   ├── desktop-extra/        # Waydroid entries
│   └── home-grid.html        # touch home-grid mockup
├── branding/                 # wallpaper / visual identity
├── configs/
│   ├── plasma/               # Plasma Desktop tablet mode
│   ├── plasma-mobile/        # Plasma Mobile overlays
│   └── autostart/
├── data/
│   └── device-matrix.tsv     # Xiaoxin / pmOS status hints
├── docs/                     # guides (see table above)
├── hooks/                    # ISO / chroot hooks
├── packages/                 # apt + apk package lists
└── scripts/
    ├── install-tablet-mode.sh
    ├── install-arm.sh
    ├── install-layer.sh
    ├── install-plasma-mobile.sh
    ├── install-waydroid.sh
    ├── setup-chinese.sh
    ├── setup-chinese-apk.sh
    ├── check-device-support.sh
    ├── pmbootstrap-hints.sh
    ├── android-linux-bridge.sh
    ├── download-base-iso.sh
    ├── remaster-iso.sh
    ├── generate-app-desktops.sh
    ├── validate.sh
    ├── ust-launch              # fullscreen app launcher
    ├── ust-start-session
    ├── ust-start-plasma-mobile
    ├── ust-waydroid
    └── lib/common.sh
```

---

## Makefile targets

| Target | Action |
|--------|--------|
| `make validate` | Syntax + file checks |
| `make desktops` | Regenerate `apps/desktop/ust-*.desktop` |
| `make install` | AMD64 tablet mode (sudo) |
| `make install-arm` | ARM Plasma Mobile path (sudo) |
| `make layer` | Configs/apps only (sudo) |
| `make waydroid` | Waydroid helper install (sudo) |
| `make chinese` | zh_CN + fcitx5 (sudo) |
| `make detect` | Print arch / distro / Plasma |
| `make device-check` | adb + device matrix |
| `make preview` | Open home-grid HTML |
| `make iso-help` | Remaster hints |

---

## Custom live ISO (amd64 only)

Needs ~**20 GB free**, root, `xorriso`, `squashfs-tools`, `rsync`:

```bash
./scripts/download-base-iso.sh
sudo ./scripts/remaster-iso.sh
# → iso/ubuntu-studio-tablet-26.04-amd64.iso
```

ISOs and remaster work trees are gitignored under `iso/`.

---

## UX principles

1. One app, full screen by default  
2. App grid home (not an empty desktop)  
3. Gesture / overview navigation  
4. Touch-sized chrome  
5. Chinese IME + OSK always ready  
6. Studio tools as first-class tablet apps (`ust-*.desktop`)

---

## Uninstall (partial)

```bash
sudo rm -rf /usr/lib/ubuntu-studio-tablet /usr/share/ubuntu-studio-tablet
sudo rm -f /usr/share/applications/ust-*.desktop
sudo rm -f /usr/share/wayland-sessions/ubuntu-studio-tablet.desktop
sudo rm -f /usr/share/xsessions/ubuntu-studio-tablet.desktop
sudo rm -f /etc/xdg/autostart/ust-tablet-session.desktop
# Restore Plasma configs from ~/.config/*.pre-ust.bak if present
```

---

## Contributing

1. Keep installers best-effort (skip missing packages; never force-flash devices).  
2. Do not add bootloader unlock or proprietary firmware blobs.  
3. Run `./scripts/validate.sh` before committing.  
4. Device matrix updates: `data/device-matrix.tsv`.

---

## License

Copyright © 2026 Ubuntu Studio Tablet contributors.

This repository’s scripts, configs, and documentation are released under the **MIT License** — see [LICENSE](LICENSE).

**Not covered by this MIT grant:**

- Ubuntu, Ubuntu Studio, and their package contents  
- KDE Plasma / Plasma Mobile  
- Individual applications (Krita, Ardour, …)  
- Waydroid / Android system images  

Use those under their respective upstream licenses. Ubuntu and Ubuntu Studio are trademarks of Canonical Ltd.
