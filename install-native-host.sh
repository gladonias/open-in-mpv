#!/usr/bin/env bash
# ==============================================================================
# install-native-host.sh — Install the native messaging host for Brave/Chromium
#
# This registers the native messaging host so the browser extension can
# communicate with the local system to launch mpv.
#
# Usage:
#   ./install-native-host.sh                  # Install (placeholder ID)
#   ./install-native-host.sh EXTENSION_ID     # Install with extension ID
#   ./install-native-host.sh --remove         # Remove
#
# License: MIT
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_NAME="com.open_in_mpv"

# Native messaging host directories for Chromium-based browsers
# Brave uses the same directory structure as Chromium
NATIVE_MSG_DIRS=(
    "$HOME/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts"
    "$HOME/.config/chromium/NativeMessagingHosts"
    "$HOME/.config/google-chrome/NativeMessagingHosts"
)

HOST_SCRIPT="$HOME/.local/bin/open-in-mpv-native-host.py"
EXTENSION_ID=""

# ---- Parse arguments ---------------------------------------------------------

for arg in "$@"; do
    case "$arg" in
        --remove|--uninstall) ACTION="remove" ;;
        *) EXTENSION_ID="$arg" ;;
    esac
done

# ---- Uninstall ---------------------------------------------------------------

if [[ "${ACTION:-}" == "remove" ]]; then
    echo "Removing native messaging host..."

    rm -f "$HOST_SCRIPT"

    for dir in "${NATIVE_MSG_DIRS[@]}"; do
        rm -f "$dir/$HOST_NAME.json"
        echo "  Removed: $dir/$HOST_NAME.json"
    done

    echo "Done."
    exit 0
fi

# ---- Install -----------------------------------------------------------------

echo "Installing native messaging host..."

# Install the Python host script
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/native-host.py" "$HOST_SCRIPT"
chmod +x "$HOST_SCRIPT"
echo "  Installed host script: $HOST_SCRIPT"

# Determine the allowed_origins value
if [[ -n "$EXTENSION_ID" ]]; then
    ORIGIN="chrome-extension://$EXTENSION_ID/"
else
    ORIGIN="chrome-extension://EXTENSION_ID_PLACEHOLDER/"
fi

# Create the native messaging host manifest in each browser's directory
for dir in "${NATIVE_MSG_DIRS[@]}"; do
    mkdir -p "$dir"

    cat > "$dir/$HOST_NAME.json" <<EOF
{
    "name": "$HOST_NAME",
    "description": "Open in mpv — Native messaging host",
    "path": "$HOST_SCRIPT",
    "type": "stdio",
    "allowed_origins": [
        "$ORIGIN"
    ]
}
EOF
    echo "  Created manifest: $dir/$HOST_NAME.json"
done

if [[ -n "$EXTENSION_ID" ]]; then
    echo ""
    echo "  Extension ID set to: $EXTENSION_ID"
    echo "  Done — no further steps needed."
else
    echo ""
    echo "============================================="
    echo "  IMPORTANT: Update the extension ID"
    echo "============================================="
    echo ""
    echo "After loading the browser extension in Brave:"
    echo "  1. Go to brave://extensions"
    echo "  2. Find 'Open in mpv' and copy the extension ID"
    echo "  3. Either re-run this script with the ID:"
    echo ""
    echo "     ./install-native-host.sh YOUR_EXTENSION_ID"
    echo ""
    echo "  Or replace it manually:"
    echo ""
    echo "  sed -i 's/EXTENSION_ID_PLACEHOLDER/YOUR_EXTENSION_ID/g' \\"

    for dir in "${NATIVE_MSG_DIRS[@]}"; do
        echo "    \"$dir/$HOST_NAME.json\" \\"
    done

    echo ""
fi
