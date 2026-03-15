#!/bin/bash
cd /home/container

# Start Xvfb virtual display (persists for entire session)
rm -f /tmp/.X99-lock 2>/dev/null
Xvfb :99 -screen 0 884x515x24 -ac &
sleep 2

# Make internal Docker IP available
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Auto-install SMAPI if not present
if [ ! -f ./StardewModdingAPI ]; then
    echo "SMAPI not found, installing from pre-baked archive..."
    mkdir -p /tmp/smapi-install
    cp /opt/smapi/smapi.zip /tmp/smapi-install/
    unzip -qo /tmp/smapi-install/smapi.zip -d /tmp/smapi-install/

    # Run the SMAPI installer with piped input
    # Input: 2 = light text, /home/container = game path, 1 = install
    INSTALLER="/tmp/smapi-install/SMAPI ${SMAPI_VERSION} installer/internal/linux/SMAPI.Installer"
    chmod +x "$INSTALLER"
    echo -e "2\n/home/container\n1\n" | "$INSTALLER"

    rm -rf /tmp/smapi-install
    echo "SMAPI installation complete."
fi

# Replace startup variables and run
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"
eval ${MODIFIED_STARTUP}
