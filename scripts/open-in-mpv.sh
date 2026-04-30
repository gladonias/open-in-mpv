#!/usr/bin/env bash
# ==============================================================================
# open-in-mpv.sh — Open a video URL directly in mpv media player
#
# This script accepts a URL (via argument or clipboard) and launches mpv
# with yt-dlp as the backend to stream videos from YouTube, Vimeo, and
# hundreds of other supported sites.
#
# Usage:
#   open-in-mpv.sh <URL>          # Pass URL as argument
#   open-in-mpv.sh --clipboard    # Read URL from clipboard
#
# Dependencies: mpv, yt-dlp, xclip (for clipboard mode), notify-send (optional)
#
# License: MIT
# ==============================================================================

set -euo pipefail

# ------------------------------- Configuration --------------------------------

# Default mpv options (adjust to your preference)
MPV_OPTS="${MPV_OPTS:---really-quiet --force-window=immediate}"

# Maximum video quality (uncomment to limit bandwidth)
# MPV_OPTS="$MPV_OPTS --ytdl-format=bestvideo[height<=?1080]+bestaudio/best"

# --------------------------------- Functions ----------------------------------

# Send a desktop notification (falls back to echo if notify-send is missing)
notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"

    if command -v notify-send &>/dev/null; then
        notify-send -u "$urgency" -a "Open in mpv" "$title" "$message"
    else
        echo "[$title] $message"
    fi
}

# Validate that a string looks like a URL
is_valid_url() {
    local url="$1"
    # Match http/https URLs
    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    fi
    return 1
}

# Check that all required dependencies are installed
check_dependencies() {
    local missing=()

    if ! command -v mpv &>/dev/null; then
        missing+=("mpv")
    fi

    if ! command -v yt-dlp &>/dev/null; then
        missing+=("yt-dlp")
    fi

    if [[ "${1:-}" == "--clipboard" ]] && ! command -v xclip &>/dev/null; then
        missing+=("xclip")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        notify "Open in mpv — Error" "Missing dependencies: ${missing[*]}" "critical"
        echo "Error: Missing dependencies: ${missing[*]}" >&2
        echo "Install them with: sudo apt install ${missing[*]}" >&2
        exit 1
    fi
}

# ----------------------------------- Main -------------------------------------

main() {
    local url=""

    # Determine URL source: argument or clipboard
    if [[ "${1:-}" == "--clipboard" ]]; then
        check_dependencies "--clipboard"
        url="$(xclip -selection clipboard -o 2>/dev/null || true)"
    elif [[ -n "${1:-}" ]]; then
        check_dependencies
        url="$1"
    else
        echo "Usage: open-in-mpv.sh <URL>  or  open-in-mpv.sh --clipboard" >&2
        exit 1
    fi

    # Trim whitespace
    url="${url#"${url%%[![:space:]]*}"}"
    url="${url%"${url##*[![:space:]]}"}"

    # Validate the URL
    if [[ -z "$url" ]]; then
        notify "Open in mpv" "Clipboard is empty — copy a video URL first." "critical"
        exit 1
    fi

    if ! is_valid_url "$url"; then
        notify "Open in mpv" "Not a valid URL: $url" "critical"
        exit 1
    fi

    # Notify the user that we're loading
    notify "Open in mpv" "Loading: $url"

    # Launch mpv with yt-dlp backend
    # shellcheck disable=SC2086
    mpv $MPV_OPTS "$url" &

    # Detach from terminal so closing the terminal won't kill mpv
    disown
}

main "$@"
