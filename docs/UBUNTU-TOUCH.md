# Ubuntu Touch — before you install

Upstream homepage: **[https://www.ubuntu-touch.io/](https://www.ubuntu-touch.io/)**  
Devices & installer: **[https://devices.ubuntu-touch.io/](https://devices.ubuntu-touch.io/)**

This page summarizes **UBports / Ubuntu Touch** guidance for people who might confuse it with **Ubuntu Studio Tablet** (this repo).  
Wording below follows the public “Before installation” / devices messaging from UBports; always re-check the live site for updates.

---

## What Ubuntu Touch is

Ubuntu Touch is **libre software** originally developed by **Canonical**, now maintained by the **UBports** community — volunteers building an ethical mobile operating system.

- Mostly **stable**, but **still missing some features**  
- Read the upstream [**Frequently Asked Questions**](https://ubports.com/community/faq) (and device page FAQs) **before** installing  
- **Not** Ubuntu Studio desktop; **not** what the amd64 Studio ISO installs  

---

## Before installation (checklist)

Stick to upstream guidelines:

1. **Be careful** with devices that are **not recently updated** (ports can rot).  
2. **Ensure the device is fully functional** on stock Android *before* flashing.  
3. **VoLTE / telephony:** communication issues (including VoLTE) may apply in **North America** — verify on your device page.  
4. **Avoid manual installation** unless you know what you are doing.  
5. **Dual booting is not supported.** Confirm support and the features you need *before* buying or wiping.  
6. Use the **UBports Installer** on listed devices to switch from Android → Ubuntu Touch.  
7. Risk is yours: UBports shares best-effort software; **the software is yours, and so is your risk in using it.**

---

## How to get a Linux device that suits you

| Path | What to do | Links |
|------|------------|--------|
| **Preinstalled commercial** | Buy a device that ships with Ubuntu Touch | [Volla](https://devices.ubuntu-touch.io/) · [Pine64](https://devices.ubuntu-touch.io/) · [FXP](https://devices.ubuntu-touch.io/) (see commercial section on devices site) · shop via upstream “Buy online” |
| **UBports Installer** | Switch from Android on a **listed** device | [Installer](https://devices.ubuntu-touch.io/installer/) · [Devices](https://devices.ubuntu-touch.io/) |
| **Native boot media** | PinePhone / PineTab-class: put the **image on the device** and boot | Device pages under [devices.ubuntu-touch.io](https://devices.ubuntu-touch.io/) |
| **Manual install** | **Discouraged** — use the installer instead | Only for unfinished/unmaintained ports; follow [docs.ubports.com](https://docs.ubports.com/) and ask the porter / device group |
| **Virtual / contrib** | No hardware? Use the platform development kit | UBports platform development kit (see [docs](https://docs.ubports.com/)) |
| **Lomiri only (PC)** | Try Lomiri as a **desktop environment on your PC** | [Lomiri website](https://lomiri.com/) · linked from [ubuntu-touch.io](https://www.ubuntu-touch.io/) |

### Commercial devices (examples)

Companies sell compatible hardware as a product (names change — verify on the live site):

- **Volla Phone** family (e.g. Volla Phone 22 and newer)  
- Other vendors listed under **Commercial Devices** on [devices.ubuntu-touch.io](https://devices.ubuntu-touch.io/)

### Community devices

Porters with a reputation for long-term commitment (examples called out upstream):

- **Fairphone 5** (and other “Community Devices” on the devices page)

### Featured tablet: Lenovo Tab M10 HD 2nd Gen (Wi‑Fi)

**Step-by-step install guide:** **[M10-HD-UBUNTU-TOUCH.md](M10-HD-UBUNTU-TOUCH.md)** (`snap run ubports-installer`, X306F checks, after-boot notes).

Affordable **10.1″** Lenovo tablet with a **mature Ubuntu Touch** community port — useful if you want a real Linux tablet *without* relying on Xiaoxin Pad / postmarketOS.

| | |
|--|--|
| **Marketing name** | Lenovo Tab M10 HD 2nd Gen Wi‑Fi 4G/64GB (confirm exact SKU) |
| **Confirm model** | **X306F** (Wi‑Fi). Do not flash a mismatched variant. |
| **UBports codename** | `amar_row_wifi` |
| **Device page** | [devices.ubuntu-touch.io/device/amar-row-wifi](https://devices.ubuntu-touch.io/device/amar-row-wifi/) |
| **24.04 (noble)** | […/release/noble](https://devices.ubuntu-touch.io/device/amar-row-wifi/release/noble/) |
| **20.04 (focal)** | […/device/amar-row-wifi](https://devices.ubuntu-touch.io/device/amar-row-wifi/) (focal channel) |
| **Stack** | **Halium 11.0** |
| **Install path** | **[UBports Installer](https://devices.ubuntu-touch.io/installer/)** (recommended) |
| **Ballpark price** | ~ **$140** (street price varies) |
| **Support state** | **Fully Optimized** — full community support; actively updated |
| **Usability (upstream beta)** | Runs very smoothly; experience comparable to other mobile OSes |

#### Hardware (typical stock specs)

- 10.1″ HD, premium metallic design  
- MediaTek **8-core ~2.3 GHz**, **2/4 GB** RAM, **32/64 GB** storage, microSD up to **1 TB**  
- **5000 mAh** battery  

#### Before flashing (device-specific)

1. Confirm the tablet is a **Lenovo Tab M10 HD Wi‑Fi (X306F)**.  
2. Device must be running **Android 11 stock firmware** before installing Ubuntu Touch (per device page).  
3. **Dual boot is not supported** — expect a full switch from Android.  
4. Use the **Installer**; avoid manual flash unless you are porting.  
5. LTE twin (if you have cellular): see [amar-row-lte](https://devices.ubuntu-touch.io/device/amar-row-lte/) — **different** codename; do not cross-flash.

#### Features reported working (community / Fully Optimized)

Upstream marks this port with broad green features across **20.04 focal** and **24.04 noble**. Highlights from the public matrix:

| Area | Working (reported) |
|------|---------------------|
| **Actors** | Manual brightness, vibration |
| **Camera** | Photo, video, camera switch |
| **Endurance** | 24+ h battery life claims, 7+ days stability |
| **GPU** | Boot to UI, hardware video playback |
| **Misc** | AppArmor patches, battery %, offline/online charging, recovery image, factory reset, SD card, RTC, shutdown/reboot, wireless external monitor, **Waydroid** |
| **Network** | Bluetooth, flight mode, Wi‑Fi, FM radio |
| **Sensors** | Auto brightness, GPS, proximity, rotation, touchscreen, double-tap to wake |
| **Sound** | Earphones, loudspeaker, mic, volume |
| **USB** | MTP, ADB |

Always re-check the live device page — matrices change when ports regress or improve.

#### After install vs this repo

You get **Ubuntu Touch (Lomiri)** + optional **Waydroid** for Android apps — not KDE Plasma / Ubuntu Studio Tablet session scripts. For Studio-class creative work, still prefer **amd64 Ubuntu Studio** or remote into it.

Matrix row: `lenovo-amar-row-wifi` in `data/device-matrix.tsv`.

### What about my device?

If it does **not** appear on the devices list **even with filters cleared**, it is **not supported**.

- Porting docs (open source): [docs.ubports.com](https://docs.ubports.com/) / porting guides on GitLab  
- Improve docs: raise issues/MRs on [gitlab.com/ubports](https://gitlab.com/ubports/)  

Typical Chinese Android tablets (e.g. many **Xiaoxin Pad** models) are **not** on the list → use **postmarketOS** (if any), **Termux/Andronix**, or **remote Studio** — see [ANDROID-ALTERNATIVES.md](ANDROID-ALTERNATIVES.md).

---

## Installer vs manual vs early ports

| Maturity | Install method |
|----------|----------------|
| **Mature devices** | Easy install via **[UBports Installer](https://devices.ubuntu-touch.io/installer/)** (recommended) |
| **Early-state ports** | Often **manual** procedure; can be complicated |
| **Unfinished / unmaintained** | Manual only for porters; ask the device group on the device page |

Installer packages (PC host):

| Host | URL |
|------|-----|
| Hub | https://devices.ubuntu-touch.io/installer/ |
| AppImage | https://devices.ubuntu-touch.io/installer?package=appimage |
| deb | https://devices.ubuntu-touch.io/installer?package=deb |
| Windows | https://devices.ubuntu-touch.io/installer?package=exe |
| macOS | https://devices.ubuntu-touch.io/installer?package=dmg |
| Snap | `snap install ubports-installer` |
| Releases | https://github.com/ubports/ubports-installer/releases/latest |

The installer downloads and flashes **recovery, kernel, and system** for your device over USB.

---

## Get help

- Device performance varies.  
- After a successful install, help others if you can (e.g. **@UBports Welcome & Install** community channels).  
- Local communities exist in many languages (including **Chinese 这里有中文**, English, Spanish, German, French, Russian, Japanese, …) — find links from the devices/help pages on [ubuntu-touch.io](https://www.ubuntu-touch.io/) / UBports.  
- UBports is a **charitable foundation** and a **volunteer** project: respectful, best-effort support.

---

## Disclaimer (upstream spirit)

UBports creates, borrows, and shares software with limited resources. Anyone may use it as they wish. **The software is yours, and so is your risk in using it.** Enjoy Ubuntu Touch.

This Ubuntu Studio Tablet repository does **not** ship Ubuntu Touch images, unlock bootloaders, or guarantee Touch on any Xiaoxin/Lenovo pad.

---

## After Ubuntu Touch boots — and this repo

Ubuntu Touch uses **Lomiri**, not KDE Plasma. The Studio Tablet scripts (`install-arm.sh`, Plasma Mobile overlays) target **Plasma 6** stacks (e.g. postmarketOS + Plasma Mobile).

| Goal | Action |
|------|--------|
| Daily Ubuntu Touch phone/tablet | Stay on Touch; use OpenStore / UT apps |
| Creative “Studio” apps on ARM Linux | Prefer **pmOS + Plasma Mobile** + `install-arm.sh`, or **amd64 Studio** |
| Experiment | You may still use individual CLI tools; do not expect full UST Plasma session on Lomiri |

Related: [ANDROID-ALTERNATIVES.md](ANDROID-ALTERNATIVES.md) · [ARM-PORT.md](ARM-PORT.md) · [https://www.ubuntu-touch.io/](https://www.ubuntu-touch.io/)
