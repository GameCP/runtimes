#!/bin/bash
set -e

# Start Xvfb
Xvfb :0 -screen 0 640x480x24 -ac &
XVFB_PID=$!
export DISPLAY=:0
sleep 2

# Install vcrun2022 (installer crashes but DLLs get extracted via cabextract)
echo "Installing vcrun2022..."
export WINEARCH=win64
export WINEPREFIX=/home/container/.wine
WINEDLLOVERRIDES="mscoree,mshtml=" winetricks -q vcrun2022 || true

# Clean up
wineserver -k || true
kill $XVFB_PID 2>/dev/null || true

# Save updated prefix to /opt
echo "Saving prefix with vcrun2022..."
rm -rf /opt/wine-prefix
cp -a /home/container/.wine /opt/wine-prefix

# Clean lock files
rm -f /tmp/.X*-lock
rm -rf /tmp/.X11-unix

echo "vcrun2022 setup complete."
