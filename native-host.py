#!/usr/bin/env python3
# ==============================================================================
# native-host.py — Native messaging host for the "Open in mpv" browser extension
#
# This script receives a JSON message from the browser extension via stdin
# (Chrome Native Messaging protocol), extracts the URL, and launches mpv.
#
# Chrome Native Messaging protocol:
#   - Messages are prefixed with a 4-byte native-endian integer (message length)
#   - The message body is JSON
#
# License: MIT
# ==============================================================================

import json
import struct
import subprocess
import sys
import os


def read_message():
    """Read a native messaging message from stdin."""
    # Read the 4-byte message length header
    raw_length = sys.stdin.buffer.read(4)
    if len(raw_length) == 0:
        sys.exit(0)

    # Unpack as a native-endian unsigned int
    message_length = struct.unpack("@I", raw_length)[0]

    # Read the message body
    message = sys.stdin.buffer.read(message_length).decode("utf-8")
    return json.loads(message)


def send_message(message):
    """Send a native messaging response back to the browser."""
    encoded = json.dumps(message).encode("utf-8")
    # Write length header + message body
    sys.stdout.buffer.write(struct.pack("@I", len(encoded)))
    sys.stdout.buffer.write(encoded)
    sys.stdout.buffer.flush()


def launch_mpv(url):
    """Launch mpv in the background with the given URL."""
    # Use the installed open-in-mpv.sh script if available;
    # otherwise fall back to calling mpv directly
    script_path = os.path.expanduser("~/.local/bin/open-in-mpv.sh")

    if os.path.isfile(script_path) and os.access(script_path, os.X_OK):
        cmd = [script_path, url]
    else:
        cmd = ["mpv", "--really-quiet", "--force-window=immediate", url]

    # Launch detached from this process so mpv outlives the native host
    subprocess.Popen(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def main():
    """Main entry point: read message, launch mpv, send response."""
    try:
        message = read_message()
        url = message.get("url", "")

        if not url:
            send_message({"status": "error", "message": "No URL provided"})
            return

        # Basic URL validation
        if not url.startswith(("http://", "https://")):
            send_message({"status": "error", "message": "Invalid URL"})
            return

        launch_mpv(url)
        send_message({"status": "ok", "message": f"Launching mpv with: {url}"})

    except Exception as e:
        send_message({"status": "error", "message": str(e)})


if __name__ == "__main__":
    main()
