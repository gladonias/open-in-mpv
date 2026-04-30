#!/usr/bin/env bash
# ==============================================================================
# install.sh — Installer for "Open in mpv"
#
# This script installs:
#   1. The core open-in-mpv.sh script to ~/.local/bin/
#   2. A .desktop file for URL handling (~/.local/share/applications/)
#   3. A Nemo action for Cinnamon's file manager right-click menu
#   4. Instructions for keyboard shortcut and browser extension setup
#
# Usage:
#   ./install.sh           # Install everything
#   ./install.sh --remove  # Uninstall everything
#
# License: MIT
# ==============================================================================

set -euo pipefail

# --------------------------------- Variables ----------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
NEMO_ACTIONS_DIR="$HOME/.local/share/nemo/actions"
SCRIPT_NAME="open-in-mpv.sh"
DESKTOP_NAME="open-in-mpv.desktop"
NEMO_ACTION_NAME="open-in-mpv.nemo_action"

# --------------------------------- Colors -------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ------------------------------- Uninstaller ----------------------------------

uninstall() {
    info "Removing Open in mpv..."

    [[ -f "$BIN_DIR/$SCRIPT_NAME" ]] && rm -f "$BIN_DIR/$SCRIPT_NAME" && success "Removed $BIN_DIR/$SCRIPT_NAME"
    [[ -f "$APPS_DIR/$DESKTOP_NAME" ]] && rm -f "$APPS_DIR/$DESKTOP_NAME" && success "Removed $APPS_DIR/$DESKTOP_NAME"
    [[ -f "$NEMO_ACTIONS_DIR/$NEMO_ACTION_NAME" ]] && rm -f "$NEMO_ACTIONS_DIR/$NEMO_ACTION_NAME" && success "Removed Nemo action"

    # Refresh desktop database
    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$APPS_DIR" 2>/dev/null || true
    fi

    success "Uninstall complete."
    exit 0
}

# -------------------------------- Installer -----------------------------------

install() {
    echo ""
    echo "============================================="
    echo "   Open in mpv — Installer"
    echo "============================================="
    echo ""

    # --- Step 1: Check dependencies -------------------------------------------
    info "Checking dependencies..."

    local deps_ok=true

    # Detect clipboard tool based on display server
    local clipboard_tool="xclip"
    local clipboard_pkg="xclip"
    if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
        clipboard_tool="wl-paste"
        clipboard_pkg="wl-clipboard"
    fi

    for dep in mpv yt-dlp "$clipboard_tool" notify-send; do
        if command -v "$dep" &>/dev/null; then
            success "Found: $dep"
        else
            if [[ "$dep" == "notify-send" ]]; then
                warn "Optional: $dep not found (desktop notifications won't work)"
            else
                error "Missing: $dep (package: ${dep})"
                deps_ok=false
            fi
        fi
    done

    if [[ "$deps_ok" == false ]]; then
        echo ""
        error "Please install missing dependencies first."
        echo "  Arch/CachyOS:    sudo pacman -S mpv yt-dlp $clipboard_pkg libnotify"
        echo "  Debian/Ubuntu:   sudo apt install mpv yt-dlp $clipboard_pkg libnotify-bin"
        echo "  Fedora:          sudo dnf install mpv yt-dlp $clipboard_pkg libnotify"
        echo ""
        exit 1
    fi

    # --- Step 2: Install the main script --------------------------------------
    info "Installing main script..."

    mkdir -p "$BIN_DIR"
    cp "$SCRIPT_DIR/scripts/$SCRIPT_NAME" "$BIN_DIR/$SCRIPT_NAME"
    chmod +x "$BIN_DIR/$SCRIPT_NAME"
    success "Installed to $BIN_DIR/$SCRIPT_NAME"

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        warn "$BIN_DIR is not in your PATH."
        echo "  Add this to your ~/.bashrc or ~/.profile:"
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
    fi

    # --- Step 3: Install .desktop file (URL handler) --------------------------
    info "Installing .desktop URL handler..."

    mkdir -p "$APPS_DIR"
    cat > "$APPS_DIR/$DESKTOP_NAME" <<EOF
[Desktop Entry]
Type=Application
Name=Open in mpv
Comment=Stream a video URL in mpv media player
Exec=$BIN_DIR/$SCRIPT_NAME %u
Icon=mpv
Terminal=false
NoDisplay=true
Categories=AudioVideo;Video;Player;
MimeType=x-scheme-handler/mpv;
EOF
    success "Installed .desktop file to $APPS_DIR/$DESKTOP_NAME"

    # Register the mpv:// protocol handler
    if command -v xdg-mime &>/dev/null; then
        xdg-mime default "$DESKTOP_NAME" x-scheme-handler/mpv 2>/dev/null || true
        success "Registered mpv:// protocol handler"
    fi

    # Refresh desktop database
    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$APPS_DIR" 2>/dev/null || true
    fi

    # --- Step 4: Install Nemo action (Cinnamon right-click menu) --------------
    info "Installing Nemo action (Cinnamon right-click)..."

    mkdir -p "$NEMO_ACTIONS_DIR"
    cat > "$NEMO_ACTIONS_DIR/$NEMO_ACTION_NAME" <<EOF
[Nemo Action]
Name=Open in mpv
Comment=Stream this video URL in mpv
Exec=$BIN_DIR/$SCRIPT_NAME %F
Selection=any
Extensions=any;
Icon-Name=mpv
EOF
    success "Installed Nemo action to $NEMO_ACTIONS_DIR/$NEMO_ACTION_NAME"

    # --- Step 5: Print post-install instructions ------------------------------
    echo ""
    echo "============================================="
    echo "   Installation Complete!"
    echo "============================================="
    echo ""

    echo -e "${GREEN}What's installed:${NC}"
    echo "  ✓ open-in-mpv.sh script in $BIN_DIR"
    echo "  ✓ .desktop URL handler (mpv:// protocol)"
    echo "  ✓ Nemo right-click action for Cinnamon"
    echo ""

    echo -e "${YELLOW}Remaining manual steps:${NC}"
    echo ""
    echo "  1. KEYBOARD SHORTCUT (recommended):"
    echo "     Open Cinnamon Settings → Keyboard → Shortcuts → Custom Shortcuts"
    echo "     Add a new shortcut:"
    echo "       Name:    Open in mpv"
    echo "       Command: $BIN_DIR/$SCRIPT_NAME --clipboard"
    echo "       Hotkey:  Ctrl+Shift+M (or your choice)"
    echo ""
    echo "  2. BROWSER EXTENSION:"
    echo "     Load the extension from the repository root folder:"
    echo "     • Open Brave → brave://extensions"
    echo "     • Enable 'Developer mode' (top right)"
    echo "     • Click 'Load unpacked' → select the open-in-mpv/ folder"
    echo "     This adds a right-click menu entry on all links in the browser."
    echo ""
    echo "  3. TEST IT:"
    echo "     $BIN_DIR/$SCRIPT_NAME https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo ""
}

# ----------------------------------- Main -------------------------------------

if [[ "${1:-}" == "--remove" ]] || [[ "${1:-}" == "--uninstall" ]]; then
    uninstall
else
    install
fi
