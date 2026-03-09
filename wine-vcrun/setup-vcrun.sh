#!/bin/bash
set -e

# Start Xvfb
Xvfb :0 -screen 0 640x480x24 -ac &
XVFB_PID=$!
export DISPLAY=:0
sleep 2

# Install vcrun2022 (installer crashes but DLLs get extracted)
echo "Installing vcrun2022..."
WINEDLLOVERRIDES="mscoree,mshtml=" winetricks -q vcrun2022 || true

# Clean up
wineserver -k || true
kill $XVFB_PID 2>/dev/null || true

echo "vcrun2022 setup complete."
