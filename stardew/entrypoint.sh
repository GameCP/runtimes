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
    chmod +x "$INSTALLER" 2>/dev/null
    echo -e "2\n/home/container\n1\n" | "$INSTALLER" || {
        echo "Interactive installer failed, trying direct file copy..."
        LINUX_DIR="/tmp/smapi-install/SMAPI ${SMAPI_VERSION} installer/internal/linux"
        if [ -d "$LINUX_DIR" ]; then
            cp -v "$LINUX_DIR"/* /home/container/ 2>/dev/null
        fi
    }

    rm -rf /tmp/smapi-install
    echo "SMAPI installation complete."
fi

# Set up default save if no saves exist
SAVES_DIR=".config/StardewValley/Saves"
if [ ! -d "$SAVES_DIR" ] || [ -z "$(ls -A "$SAVES_DIR" 2>/dev/null)" ]; then
    echo "No saves found, downloading default save..."
    mkdir -p "$SAVES_DIR"
    curl -sL "https://dl.gamecp.com/stardew/default-save.zip" -o /tmp/default-save.zip
    if [ -f /tmp/default-save.zip ]; then
        unzip -qo /tmp/default-save.zip -d "$SAVES_DIR/"
        rm -f /tmp/default-save.zip
        echo "Default save installed."
    else
        echo "WARNING: Could not download default save."
    fi
fi

# Set up startup_preferences for headless server mode
PREFS_DIR=".config/StardewValley"
mkdir -p "$PREFS_DIR"
if [ ! -f "$PREFS_DIR/startup_preferences" ]; then
    # Find the save folder name
    SAVE_NAME=$(ls -1 "$SAVES_DIR" 2>/dev/null | head -1)
    cat > "$PREFS_DIR/startup_preferences" << EOF
<?xml version="1.0" encoding="utf-8"?>
<StartupPreferences xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <startMuted>false</startMuted>
  <timesPlayed>2</timesPlayed>
  <windowMode>0</windowMode>
  <playerLimit>-1</playerLimit>
  <fullscreenResolutionX>884</fullscreenResolutionX>
  <fullscreenResolutionY>515</fullscreenResolutionY>
  <lastEnteredIP />
  <languageCode>en</languageCode>
  <lastFileLoaded>${SAVE_NAME}</lastFileLoaded>
  <clientOptions>
    <fullscreen>false</fullscreen>
    <windowedBorderlessFullscreen>true</windowedBorderlessFullscreen>
    <ipConnectionsEnabled>true</ipConnectionsEnabled>
    <enableServer>true</enableServer>
    <enableFarmhandCreation>true</enableFarmhandCreation>
    <serverPrivacy>FriendsOnly</serverPrivacy>
    <musicVolumeLevel>0</musicVolumeLevel>
    <soundVolumeLevel>0</soundVolumeLevel>
    <footstepVolumeLevel>0</footstepVolumeLevel>
    <ambientVolumeLevel>0</ambientVolumeLevel>
    <preferredResolutionX>884</preferredResolutionX>
    <preferredResolutionY>515</preferredResolutionY>
  </clientOptions>
</StartupPreferences>
EOF
    echo "Startup preferences configured (save: ${SAVE_NAME:-none}, server: enabled, IP connections: enabled)"
fi

# Replace startup variables and run
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"
eval ${MODIFIED_STARTUP}
