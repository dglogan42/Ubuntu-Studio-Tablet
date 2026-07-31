# Linux on Android tablets — what actually works

**Running a full desktop OS like Ubuntu Studio directly on an Android tablet is not natively supported.**

Ubuntu Studio 26.04 ships as an **amd64** desktop image. Most Chinese Android tablets (Xiaoxin Pad, MediaTek / Qualcomm) are **ARM64** and boot **Android**. This project is a **Plasma configuration layer** for a machine that already runs Linux — it does **not** replace Android by itself, unlock bootloaders, or ship device kernels.

Use one of the paths below depending on how deep you want to go.

---

## At a glance

| Approach | Replaces Android? | Full desktop DE? | Fits this repo? |
|----------|-------------------|------------------|-----------------|
| **Ubuntu Studio ISO (amd64)** | N/A — PC/laptop only | Yes | **Primary** — `install-tablet-mode.sh` |
| **Ubuntu Touch** | Yes (supported devices only) | Mobile shell, not Studio desktop | Port first → maybe layer later |
| **postmarketOS** | Yes (if device port exists) | Plasma Mobile possible | **ARM path** — then `install-arm.sh` |
| **Andronix** | No — runs on Android | XFCE / LXQt via proot | CLI/GUI experiments only |
| **Termux** | No | CLI (+ optional Termux:X11) | Scripts / remote helper only |
| **Remote into AMD64 Studio** | No | Full Studio on the PC | **Recommended creative path** |

---

## Mobile Linux operating systems (replace Android)

These install a real Linux userspace as the device OS. You need **device support** (kernel, display, touch, modem optional). This repo never flashes firmware.

### Ubuntu Touch

A mobile-friendly Ubuntu-derived system for **phones and tablets** that **replaces Android entirely** on **supported** hardware.

- Project / devices: [ubuntu-touch.io](https://ubuntu-touch.io/) / UBports  
- **Not** the same as Ubuntu Studio desktop  
- Only useful here if your exact tablet model is supported and you can boot Touch first  

After a working session, creative apps are limited compared with amd64 Studio; treat UST scripts as optional experiments, not a guarantee.

### postmarketOS

A lightweight, touch-oriented system based on **Alpine Linux**, designed for mobile devices.

- Device wiki: [wiki.postmarketos.org/wiki/Devices](https://wiki.postmarketos.org/wiki/Devices)  
- Prefer a **Plasma Mobile** UI image when available  
- Once Plasma 6 boots: run this repo’s ARM installer  

```bash
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative --with-waydroid
```

See **[ARM-PORT.md](ARM-PORT.md)** and **[PLASMA-MOBILE.md](PLASMA-MOBILE.md)**.

### Other ARM bases

Mobian, Ubuntu arm64 images, or vendor mainline ports — same rule: **working Linux first**, then UST layer (`install-arm.sh` / `install-layer.sh`).

---

## Running Linux *inside* Android (Android stays)

No bootloader unlock required for the common options. You do **not** get a native KMS/DRM Plasma session or low-latency Ubuntu Studio DAW stack.

### Andronix

An app that installs full Linux **desktop environments** (e.g. **XFCE**, **LXQt**) on top of your existing Android system, typically via **Termux** + proot-style containers.

| Good for | Weak for |
|----------|----------|
| Trying Ubuntu/Debian GUI apps without wiping Android | Real-time audio, GPU-heavy video, “native tablet OS” feel |
| Learning Linux packages on a pad | Running `install-tablet-mode.sh` as the device shell |

Treat Andronix as a **sandbox**, not a substitute for amd64 Studio hardware.

### Termux

A powerful Android **terminal emulator** that provides a Linux command-line environment and packages **directly on the tablet** (no root for basic use; prefer F-Droid builds).

Typical flow:

```text
Install Termux → pkg update → proot-distro install ubuntu → proot-distro login ubuntu
```

Optional: **Termux:X11** for a nested GUI.

| Good for | Weak for |
|----------|----------|
| CLI tools, scripts, SSH, light packages | Plasma Mobile as the real home screen |
| Bridge workflows (`android-linux-bridge.sh`) | Hardware RT audio / full Studio session |

Print the built-in bridge guide from this repo:

```bash
./scripts/android-linux-bridge.sh --termux
./scripts/android-linux-bridge.sh --print-all
```

### Root / chroot (Linux Deploy, etc.)

Still shares the **Android kernel**. Higher risk (unlock/root), often janky for full desktop shells. Prefer remote Studio or a real port when possible. See Path C3 in `android-linux-bridge.sh`.

---

## Recommended creative workflows

### 1. AMD64 laptop / mini-PC (best)

1. Install **Ubuntu Studio 26.04** from the official ISO.  
2. `sudo ./scripts/install-tablet-mode.sh`  
3. Optional: `sudo ./scripts/setup-chinese.sh`  

Xiaoxin **laptop** dual-boot: **[XIAOXIN-LAPTOP.md](XIAOXIN-LAPTOP.md)**.

### 2. Keep Android tablet + remote Studio host

- PC: Ubuntu Studio + Sunshine / RDP / similar  
- Tablet: Moonlight / remote desktop / scrcpy  
- Full DAW and video on real hardware; pad is glass + touch  

```bash
./scripts/android-linux-bridge.sh --remote
```

### 3. Real ARM Linux port, then UST layer

Only if postmarketOS / Ubuntu Touch / mainline exists for **your exact model**.

1. **[ARM-PORT.md](ARM-PORT.md)**  
2. **[ARM.md](ARM.md)** + **[PLASMA-MOBILE.md](PLASMA-MOBILE.md)**  
3. Optional Android apps on Linux: **[WAYDROID.md](WAYDROID.md)** (opposite direction of Andronix)

### 4. Android-only Linux toys

Andronix / Termux for learning and light tools — **not** claimed as “Ubuntu Studio on the Pad.”

---

## How this relates to Ubuntu Studio Tablet

```
Android tablet (stock)
        │
        ├─► Stay on Android ──► Termux / Andronix (nested Linux)
        │                   └──► Remote into amd64 Studio  ← recommended
        │
        └─► Replace Android (supported devices only)
                  Ubuntu Touch / postmarketOS / mainline
                        └──► then install-arm.sh (this repo)
```

**Never expected:** flashing the Ubuntu Studio **amd64** ISO onto a typical ARM Android pad and getting a working Studio desktop.

---

## Related docs

| Doc | Topic |
|-----|--------|
| [XIAOXIN.md](XIAOXIN.md) | Laptop vs Pad |
| [ARM-PORT.md](ARM-PORT.md) | Get ARM Linux booting first |
| [WAYDROID.md](WAYDROID.md) | Android apps *on* Linux (not Linux on Android) |
| `scripts/android-linux-bridge.sh` | Termux / remote / chroot cheat sheets |
