# Lenovo Tab M10 HD → Ubuntu Touch (quick start)

**This is the supported path for a cheap Lenovo “M10” tablet.**  
You get **Ubuntu Touch (Lomiri)** with a **device Halium kernel** — **not** Ubuntu Studio and **not** the PC’s `7.0.0-*-generic` kernel.

| | |
|--|--|
| **Confirm model** | **TB-X306F / X306F** (Wi‑Fi 2nd Gen) |
| **UBports codename** | `amar_row_wifi` |
| **Stack** | Halium **11.0** |
| **Installer** | [UBports Installer](https://devices.ubuntu-touch.io/installer/) |
| **Device page** | https://devices.ubuntu-touch.io/device/amar-row-wifi/ |
| **24.04 noble** | https://devices.ubuntu-touch.io/device/amar-row-wifi/release/noble/ |
| **Status** | Fully Optimized · Installer · actively updated · ~$140 street |
| **LTE twin** | X306X class → [amar-row-lte](https://devices.ubuntu-touch.io/device/amar-row-lte/) (do **not** cross-flash) |

Upstream messaging and feature matrix: **[UBUNTU-TOUCH.md](UBUNTU-TOUCH.md)**.  
Matrix row: `lenovo-amar-row-wifi` in `data/device-matrix.tsv`.

---

## What you are *not* doing

| Wrong path | Why |
|------------|-----|
| Ubuntu Studio **amd64 ISO** on the M10 | Wrong architecture / product |
| Generic Linux **7.0** kernel from your PC | Not a Halium device image |
| Flashing Xiaoxin Pad guides | Different SoC / no UT port for most Pads |
| Dual-boot Android + Touch | **Not supported** by UBports |

---

## Checklist before unlock

1. **About tablet** shows **X306F** (Wi‑Fi). If LTE / other M10 SKU, stop and use the correct device page.  
2. Tablet is **fully functional** on stock Android.  
3. Running **Android 11 stock** (required by the device page — reflash stock if needed).  
4. **Backup** photos/apps; expect a full wipe.  
5. Battery charged; use a **data** USB cable to a PC.  
6. Read the live device page once more (steps change).

---

## Install (PC + tablet)

### On Ubuntu (recommended host)

```bash
# if not already installed:
sudo snap install ubports-installer

snap run ubports-installer
# or: ubports-installer
```

Other hosts: https://devices.ubuntu-touch.io/installer/ (AppImage, deb, Windows, macOS).

### Flash

1. Follow Installer + **device page** for bootloader unlock / mode entry (MediaTek / Lenovo).  
2. Select **Lenovo Tab M10 HD 2nd Gen** / **`amar_row_wifi`**.  
3. Choose a supported channel (**20.04 focal** and/or **24.04 noble** as offered).  
4. Let the Installer download and flash **recovery + Halium kernel + system**.  
5. First boot → **Ubuntu Touch**.

Do **not** sideload random partition zips unless you are a porter and know the risks.

---

## After first boot

- Complete setup (language, Wi‑Fi).  
- Apps: OpenStore; **Waydroid** is reported working on this port.  
- USB: MTP / ADB when enabled in settings.  
- Features (upstream Fully Optimized matrix): Wi‑Fi, BT, cameras, sensors, SD, charging, wireless external monitor, etc. — re-check the [device page](https://devices.ubuntu-touch.io/device/amar-row-wifi/) for regressions.

### vs this repo (Ubuntu Studio Tablet)

| Want | Do |
|------|-----|
| Daily driver M10 tablet | Stay on **Ubuntu Touch** |
| Krita / Ardour / Studio desktop | Use an **amd64** PC with Ubuntu Studio, or remote into it from the M10 |
| Plasma Mobile + `install-arm.sh` | **Different** stack (e.g. postmarketOS) — not this UT image |

```bash
# From a clone of this repo, identify the tablet while still on Android:
./scripts/check-device-support.sh --adb
# or:
./scripts/check-device-support.sh --model X306F
./scripts/check-device-support.sh --codename lenovo-amar-row-wifi
```

---

## Troubleshooting

| Symptom | Action |
|---------|--------|
| Installer won’t see device | Data cable, unlock mode, udev rules, try another USB port |
| Wrong model warning | Confirm **X306F** vs X306X / older M10 |
| Need stock again | Use stock ROM + tools linked from the UBports device page |
| Want help | Device group / Welcome & Install linked from [devices.ubuntu-touch.io](https://devices.ubuntu-touch.io/) |

---

## Related

- [UBUNTU-TOUCH.md](UBUNTU-TOUCH.md) — before-install rules, commercial devices, disclaimer  
- [ANDROID-ALTERNATIVES.md](ANDROID-ALTERNATIVES.md) — Touch vs pmOS vs Termux vs Studio  
- [XIAOXIN.md](XIAOXIN.md) — Pad vs laptop vs this M10  
- PC Studio layer: [INSTALL.md](INSTALL.md) (amd64 only)
