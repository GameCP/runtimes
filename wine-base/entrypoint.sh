#!/bin/bash
cd /home/container

# Start Xvfb virtual display (persists for entire session)
Xvfb :0 -screen 0 640x480x24 -ac &
sleep 1

# Make internal Docker IP available
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Run any additional winetricks if needed (from WINETRICKS_RUN env)
if [ -n "$WINETRICKS_RUN" ] && [ ! -f "$WINEPREFIX/.winetricks_done" ]; then
    echo "Installing Wine dependencies: $WINETRICKS_RUN"
    for trick in $WINETRICKS_RUN; do
        echo "  Installing $trick..."
        winetricks -q $trick 2>&1 || echo "  WARNING: $trick may have failed, continuing..."
    done
    touch "$WINEPREFIX/.winetricks_done"
    echo "Dependencies installed."
fi

# Re-enable mscoree for the game
export WINEDLLOVERRIDES="mshtml="

# Replace startup variables and run
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"
eval ${MODIFIED_STARTUP}
