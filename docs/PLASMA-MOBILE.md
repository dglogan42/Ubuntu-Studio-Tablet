# Plasma Mobile adaptation

Ubuntu Studio Tablet on ARM defaults to **Plasma Mobile** so each creative app behaves like a **native phone/tablet app**: full screen, gesture navigation, OSK, app drawer.

## Session

| File | Purpose |
|------|---------|
| `scripts/ust-start-plasma-mobile` | Sets IM/mobile env, seeds configs, execs `startplasmamobile` |
| `/usr/share/wayland-sessions/ubuntu-studio-tablet.desktop` | Login entry |

Fallback order:

1. `/usr/bin/startplasmamobile`
2. `/usr/lib/libexec/plasma-mobile/startplasmamobile`
3. `/usr/bin/plasma-mobile`
4. `startplasma-wayland` with `PLASMA_PLATFORM=phone:handheld`

## Config overlays (`configs/plasma-mobile/`)

| File | Effect |
|------|--------|
| `kwinrc` | Tablet mode on, borderless maximize, overview edge, Maliit IM |
| `kdeglobals` | Breeze Dark, CJK fonts, phone look-and-feel if present |

Shared with desktop mode:

- `configs/plasma/kwinrulesrc` — per-app fullscreen rules (Krita, Ardour, …)
- `configs/plasma/kxkbrc` — CN/US layouts

## App model

Plasma Mobile already opens applications full-screen.  
`ust-launch` still:

- Sets Wayland + mobile Qt flags  
- Sets fcitx5 modules  
- Best-effort maximize for XWayland apps  

`.desktop` files use:

```ini
X-KDE-FormFactor=tablet;handset;desktop;
X-Ubuntu-Studio-Tablet=true
```

## Install

```bash
sudo ./scripts/install-plasma-mobile.sh
sudo ./scripts/install-layer.sh mobile
# or all-in-one:
sudo ./scripts/install-arm.sh --ui plasma-mobile
```

## Packages

- Ubuntu/Debian: `packages/plasma-mobile-apt.list`  
- postmarketOS: `packages/plasma-mobile-apk.list` (includes `postmarketos-ui-plasma-mobile`)

## Gestures (typical)

- Bottom swipe / home: return to launcher  
- Edge overview: task switcher (KWin overview)  
- Long-press icons: app context menus  

Exact gestures depend on Plasma Mobile version.

## Coexistence with Plasma Desktop

You can install both sessions and pick at login.  
Layer mode `mobile` vs `desktop` only changes which configs are copied to skel/homes.
