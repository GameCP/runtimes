#!/bin/bash
cd /home/container

# Start Xvfb virtual display (persists for entire session)
rm -f /tmp/.X99-lock 2>/dev/null
Xvfb :99 -screen 0 884x515x24 -ac &
sleep 2

# Make internal Docker IP available
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace startup variables and run
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"
eval ${MODIFIED_STARTUP}
