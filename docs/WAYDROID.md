# Waydroid integration (Android apps on ARM Linux)

Waydroid runs a containerized Android system so you can use **Android-only apps** (WeChat, banking, Chinese app stores) next to Plasma Mobile + Studio tools.

## Requirements

| Need | Notes |
|------|--------|
| **aarch64 or x86_64** | ARM tablets use aarch64 images |
| **Kernel binder** | `CONFIG_ANDROID_BINDER_IPC` / `binderfs` |
| **Wayland session** | Plasma Mobile / Desktop Wayland |
| **~2–4 GB free** | System image + apps |
| **CPU virtualization** | Not always required for Waydroid, but kernel features are |

Many **stock Android vendor kernels** already have binder; **mainline** kernels on tablets may need a custom build.

## Install (this repo)

```bash
sudo ./scripts/install-waydroid.sh
# or during ARM install:
sudo ./scripts/install-arm.sh --ui plasma-mobile --with-waydroid
```

Helper:

```bash
ust-waydroid ui          # full Android UI (fullscreen-ish)
ust-waydroid list        # installed packages
ust-waydroid app <pkg>   # launch one app
ust-waydroid install x.apk
ust-waydroid status
ust-waydroid stop
```

App drawer entry: **安卓应用 / Android Apps** (`ust-waydroid.desktop`).

## First boot checklist

1. `waydroid status` → Container running  
2. `ust-waydroid ui` → Android boots to launcher  
3. Enable network inside Android (usually bridged)  
4. Install APKs via `ust-waydroid install` or Aurora Store / F-Droid inside Android  
5. Optional GAPPS: `waydroid init -s GAPPS` (privacy tradeoffs)

## Multi-window / tablet props

The installer tries:

```bash
waydroid prop set persist.waydroid.multi_windows true
```

You can also set resolution to match the panel:

```bash
waydroid prop set persist.waydroid.width 1600
waydroid prop set persist.waydroid.height 2560
# values depend on your display
```

## Integration with Studio Tablet UX

| Use case | Approach |
|----------|----------|
| WeChat / Alipay | Waydroid full UI or single `app` launch |
| Krita / Audacity | Native Linux `ust-*.desktop` |
| Side-by-side | Plasma Mobile task switcher between Waydroid surface and Linux apps |
| Clipboard | Waydroid clipboard sync varies; test on device |

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Failed to start binder` | Kernel lacks binder; need device kernel module or custom kernel |
| Black screen | GPU / Wayland backend; try nested X11 session for test; update Mesa |
| No network | `waydroid prop set persist.waydroid.udevd true`; check nftables/firewall |
| Very slow | Free RAM; disable animations; avoid GAPPS if possible |
| Secure apps detect root/container | Expected limitation of Waydroid |

## Security notes

- Treat Waydroid like a second phone: limit app list, no banking if policy forbids containers.  
- Keep host and Android images updated.  
- Do not share root ADB casually on shared tablets.

## Upstream docs

- https://docs.waydro.id/  
- https://wiki.postmarketos.org/wiki/Waydroid (if using pmOS)
