# Lenovo Xiaoxin Pro / Pad Pro — hardware guide

## Laptop vs tablet (same brand name, different world)

| Product | Typical hardware | Install Ubuntu? | This project |
|---------|------------------|-----------------|--------------|
| **Xiaoxin Pro laptop** (notebook / 2-in-1) | Intel/AMD **x86_64** | **Yes** — standard USB install | **Primary path** |
| **Xiaoxin Pad Pro** (Android tablet) | Snapdragon / Dimensity **ARM64** | Not with amd64 ISO | [ARM-PORT.md](ARM-PORT.md) |

### Xiaoxin Pro **laptop** — start here

Full walkthrough (BIOS, USB, installer, then Studio Tablet layer):

→ **[XIAOXIN-LAPTOP.md](XIAOXIN-LAPTOP.md)**

Summary: bootable USB → F2 BIOS (disable Secure Boot) → F12 boot menu → Install Ubuntu/Studio → `install-tablet-mode.sh`.

## Reality check (Pad / ARM vs laptop / x86)

| Line | Typical SoC | Architecture | Ubuntu Studio 26.04 AMD64 ISO |
|------|-------------|--------------|-------------------------------|
| **Xiaoxin Pro laptop** | Intel Core / AMD Ryzen | **AMD64** | **Supported** |
| Xiaoxin Pad Pro 12.7 (2025) | Dimensity 8300 | **ARM64** | Not bootable |
| Xiaoxin Pad Pro GT | Snapdragon 8 Gen series | **ARM64** | Not bootable |
| Xiaoxin Pad Pro 11.x older | Snapdragon 870 / Dimensity | **ARM64** | Not bootable |
| Yoga / ThinkBook 2-in-1 “Xiaoxin” | Intel Core | **AMD64** | Supported |
| Generic Chinese x86 mini-PC | Intel N100 / i3/i5 | **AMD64** | Supported |

“Xiaoxin Pro” alone is ambiguous — **confirm laptop vs Pad** before downloading an ISO.

## Recommended paths

### Path A — Xiaoxin Pro **laptop** / AMD64 2-in-1 (recommended)

1. Follow **[XIAOXIN-LAPTOP.md](XIAOXIN-LAPTOP.md)** (USB + BIOS + installer).  
2. Prefer **Ubuntu Studio 26.04** ISO for creative apps out of the box.  
3. Run `sudo ./scripts/install-tablet-mode.sh`.  
4. Run `sudo ./scripts/setup-chinese.sh` for zh_CN + fcitx5.  
5. On convertibles: enable tablet behavior; calibrate touch/pen if present.

### Path B — ARM Xiaoxin tablet (cannot use the AMD64 ISO)

There is **no official Ubuntu Studio ARM ISO** matching that cdimage link. **Supported approach in this repo:**

```bash
# On device after Ubuntu arm64 / postmarketOS / Mobian is running:
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

**First:** get a working ARM Linux port — **[ARM-PORT.md](ARM-PORT.md)**  
(`./scripts/check-device-support.sh --adb`).

Then: **[ARM.md](ARM.md)** · **[PLASMA-MOBILE.md](PLASMA-MOBILE.md)** · **[WAYDROID.md](WAYDROID.md)**

Other practical approaches:

1. **postmarketOS** if your exact model is in the [device list](https://wiki.postmarketos.org/wiki/Devices) — pick Plasma Mobile UI, then `install-arm.sh`.
2. **Keep Android** + remote into an AMD64 Studio machine (Sunshine / RDP / KDE Connect).
3. **Waydroid** on the Linux ARM base for WeChat etc., Linux apps for creation.
4. **External Studio host**: tablet as thin client for heavy DAW/video.

The **UX layer** (`configs/`, `apps/`, `scripts/ust-launch`) is architecture-independent.

### Path C — Dual role

- Xiaoxin tablet: sketch / reference / control surface (Android).
- Mini-PC or laptop: Ubuntu Studio Tablet session for heavy DAW / video.

## Touch & sensors checklist (AMD64)

- [ ] Multi-touch works (`libinput list-devices`, `libinput debug-events`)
- [ ] Screen rotation via `iio-sensor-proxy` (or disable if lid sensor flaky)
- [ ] On-screen keyboard appears on text focus
- [ ] Pen pressure (if any) in Krita
- [ ] Audio low-latency (Ubuntu Studio JACK/PipeWire defaults preserved)
- [ ] Chinese IME: fcitx5 Pinyin selectable from tray / gesture

## Chinese mirrors (optional, faster in CN)

```bash
# Example: Tsinghua Ubuntu mirror (adjust for 26.04 / resolute as needed)
sudo sed -i 's|http://archive.ubuntu.com/ubuntu|https://mirrors.tuna.tsinghua.edu.cn/ubuntu|g' /etc/apt/sources.list
# Also check /etc/apt/sources.list.d/*
sudo apt update
```

## Boot / install media

Official ISO is **6.7 GB** — needs **USB ≥ 8 GB**, not FAT32-only burns. Use `dd`, Balena Etcher, or `usb-creator`.
