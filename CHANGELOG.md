# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-04-30

### Added

- Wayland clipboard support via `wl-clipboard` (auto-detected alongside X11's `xclip`)
- `install-native-host.sh` now accepts the extension ID as a CLI argument

### Fixed

- `install.sh` post-install instructions referenced a non-existent `browser-extension/` directory
- `install.sh` dependency error message now shows commands for Arch, Debian, and Fedora
- URL trimming no longer uses `echo | xargs`, which could mangle URLs with backslashes

## [0.1.0] - 2026-04-30

### Added

- Core `open-in-mpv.sh` script for playing URLs via mpv + yt-dlp
- Clipboard mode (`--clipboard`) for keyboard shortcut integration
- Chromium browser extension (Manifest V3) with right-click context menu
- Native messaging host (`native-host.py`) for browser-to-system communication
- Fallback to `mpv://` protocol handler when native messaging is unavailable
- `install.sh` installer for the core script, `.desktop` URL handler, and Nemo action
- `install-native-host.sh` installer for the browser native messaging host
- Desktop notifications via `notify-send`
- Configurable mpv options via `MPV_OPTS` environment variable
- Nemo file manager right-click action (Cinnamon desktop)
- MIT license
