.PHONY: validate desktops install install-arm detect device-check chinese preview iso-help layer mobile waydroid port-help

validate:
	./scripts/validate.sh

desktops:
	./scripts/generate-app-desktops.sh apps/desktop

detect:
	./scripts/detect-platform.sh

device-check:
	./scripts/check-device-support.sh --adb

port-help:
	@echo "docs/ARM-PORT.md — get Linux booting before install-arm.sh"
	./scripts/android-linux-bridge.sh --print-all | head -40

install:
	sudo ./scripts/install-tablet-mode.sh

install-arm:
	sudo ./scripts/install-arm.sh --ui plasma-mobile --with-creative

layer:
	sudo ./scripts/install-layer.sh mobile

mobile:
	sudo ./scripts/install-plasma-mobile.sh

waydroid:
	sudo ./scripts/install-waydroid.sh

chinese:
	sudo ./scripts/setup-chinese.sh

preview:
	@echo "Open apps/home-grid.html in a browser"
	xdg-open apps/home-grid.html 2>/dev/null || python3 -m http.server -d apps 8765

iso-help:
	@echo "1) ./scripts/download-base-iso.sh"
	@echo "2) sudo ./scripts/remaster-iso.sh"
	@echo "Requires ~20GB free disk (AMD64 only)"
