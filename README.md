# Open in mpv

Stream any video URL directly in [mpv](https://mpv.io/) from your browser, clipboard, or file manager on Linux.

Copy a link and press a hotkey, or right-click any link in your browser -- mpv starts playing immediately. Supports YouTube, Vimeo, Twitch, Twitter/X, Reddit, and [1000+ sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) via yt-dlp.

## How It Works

| Method | How | Best for |
|---|---|---|
| Keyboard shortcut | Copy a URL, press `Ctrl+Shift+M` | Chat apps, emails, anywhere on the desktop |
| Browser right-click | Right-click any link, select "Open in mpv" | Browsing the web |
| Nemo right-click | Right-click a file in Nemo file manager | Local media files |

## Dependencies

| Package | Required | Purpose |
|---|---|---|
| `mpv` | Yes | Media player |
| `yt-dlp` | Yes | Fetches streams from YouTube and other sites |
| `xclip` | Yes (X11) | Reads URLs from the clipboard |
| `libnotify` / `notify-send` | Optional | Desktop notifications |
| `python3` | Yes (browser extension only) | Runs the native messaging host |

### Installing dependencies

Arch / CachyOS:

```bash
sudo pacman -S mpv yt-dlp xclip libnotify python
```

Debian / Ubuntu:

```bash
sudo apt install mpv yt-dlp xclip libnotify-bin python3
```

Fedora:

```bash
sudo dnf install mpv yt-dlp xclip libnotify python3
```

If your distro's `yt-dlp` is outdated, install the latest version directly:

```bash
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```

## Installation

```bash
git clone https://codeberg.org/gadonias/open-in-mpv.git
cd open-in-mpv
./install.sh
```

This installs:

- `open-in-mpv.sh` to `~/.local/bin/`
- A `.desktop` file for the `mpv://` protocol handler
- A Nemo right-click action (Cinnamon desktop)

To uninstall:

```bash
./install.sh --remove
```

## Setup

### 1. Keyboard Shortcut (works everywhere)

1. Open **System Settings > Keyboard > Shortcuts > Custom Shortcuts**
2. Add a new shortcut:
   - **Name:** Open in mpv
   - **Command:** `~/.local/bin/open-in-mpv.sh --clipboard`
   - **Hotkey:** `Ctrl+Shift+M` (or your preference)
3. Copy any video URL, press the hotkey, and mpv starts playing.

### 2. Browser Extension (Brave / Chrome / Chromium)

#### Step 1: Load the extension

1. Go to `brave://extensions` (or `chrome://extensions`)
2. Enable **Developer mode** (top-right toggle)
3. Click **Load unpacked** and select this repository's root folder
4. Copy the **Extension ID** shown on the card

#### Step 2: Install the native messaging host

Pass your extension ID directly:

```bash
./install-native-host.sh YOUR_EXTENSION_ID
```

If you don't have the ID yet, run without it and re-run later once you do.

To uninstall the native host:

```bash
./install-native-host.sh --remove
```

#### Step 3: Test it

Right-click any video link in the browser and select **"Open in mpv"**.

If native messaging fails, the extension falls back to the `mpv://` protocol handler automatically.

### 3. Nemo File Manager Action

Installed automatically by `install.sh`. Right-click any file in Nemo to see the "Open in mpv" option.

## Usage

```bash
# Play a URL directly
open-in-mpv.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Play from clipboard
open-in-mpv.sh --clipboard

# Play a Twitch stream
open-in-mpv.sh "https://www.twitch.tv/shroud"
```

## Configuration

Customize mpv's behavior with the `MPV_OPTS` environment variable:

```bash
# Limit to 1080p
export MPV_OPTS="--really-quiet --force-window=immediate --ytdl-format=bestvideo[height<=?1080]+bestaudio/best"

# Start fullscreen
export MPV_OPTS="--really-quiet --force-window=immediate --fs"
```

Add your preferred `MPV_OPTS` to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) to make it permanent.

For site-specific options (e.g., passing browser cookies to yt-dlp), add to `~/.config/mpv/mpv.conf`:

```
ytdl-raw-options=cookies-from-browser=brave
```

## Project Structure

```
open-in-mpv/
├── scripts/
│   └── open-in-mpv.sh              # Core script (URL -> mpv)
├── background.js                    # Browser extension service worker
├── manifest.json                    # Chromium extension manifest (MV3)
├── native-host.py                   # Native messaging host (Python)
├── install.sh                       # Main installer / uninstaller
├── install-native-host.sh           # Native messaging host installer
├── CHANGELOG.md
├── LICENSE.md
└── README.md
```

## Troubleshooting

**mpv says "Failed to open"**
Make sure `yt-dlp` is up to date: `yt-dlp -U`

**Keyboard shortcut doesn't work**
Check that `xclip` is installed and `~/.local/bin` is in your `PATH`.

**Browser extension shows no right-click menu**
Check `brave://extensions` -- the extension must be enabled. Open the console (F12) for errors.

**Native messaging errors in the browser console**
Verify the extension ID in `~/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts/com.open_in_mpv.json` matches your actual extension ID.

**"No video" on some sites**
Some sites need cookies. Add `ytdl-raw-options=cookies-from-browser=brave` to `~/.config/mpv/mpv.conf`.

## License

[MIT](LICENSE.md)
