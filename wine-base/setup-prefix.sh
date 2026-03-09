#!/bin/bash
set -e

# Start Xvfb for the duration of setup
Xvfb :0 -screen 0 640x480x24 -ac &
XVFB_PID=$!
export DISPLAY=:0
sleep 2

# Initialize Wine prefix
echo "Initializing Wine prefix..."
WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init
sleep 5
echo "Wine prefix created."

# Download and install Wine Mono
MONO_VER=9.4.0
echo "Downloading Wine Mono ${MONO_VER}..."
wget -q -O /home/container/.cache/wine-mono-${MONO_VER}-x86.msi \
    https://dl.winehq.org/wine/wine-mono/${MONO_VER}/wine-mono-${MONO_VER}-x86.msi

echo "Installing Wine Mono..."
wine msiexec /i /home/container/.cache/wine-mono-${MONO_VER}-x86.msi /qn
sleep 2
echo "Wine Mono installed."

# Clean up
wineserver -k || true
kill $XVFB_PID 2>/dev/null || true

# Move prefix to /opt so it survives volume mounts
echo "Saving prefix to /opt/wine-prefix..."
cp -a /home/container/.wine /opt/wine-prefix
cp -a /home/container/.cache /opt/wine-cache

# Clean up lock files so they don't persist in the image
rm -f /tmp/.X*-lock
rm -rf /tmp/.X11-unix

echo "Wine prefix setup complete."
