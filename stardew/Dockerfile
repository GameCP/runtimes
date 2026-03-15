# -----------------------------------------------
# GameCP Stardew Valley Runtime
# Pre-bakes Xvfb, Mesa OpenGL, SMAPI 4.5.1 and
# compatible server mods for headless multiplayer.
# -----------------------------------------------
FROM            ghcr.io/parkervcp/yolks:debian

LABEL           maintainer="GameCP Team"
LABEL           org.opencontainers.image.source="https://github.com/gamecp/runtimes"
LABEL           org.opencontainers.image.licenses=MIT

# Install X11/OpenGL/audio dependencies for headless Stardew Valley
RUN             apt update -y \
                && apt install -y --no-install-recommends \
                    xvfb \
                    xauth \
                    libgl1-mesa-dri \
                    libgl1 \
                    libglx-mesa0 \
                    mesa-utils \
                    libopenal1 \
                    libsdl2-2.0-0 \
                    unzip \
                    curl \
                && rm -rf /var/lib/apt/lists/*

# Pre-download SMAPI installer to /opt/smapi
ENV             SMAPI_VERSION=4.5.1
RUN             mkdir -p /opt/smapi \
                && curl -sL "https://github.com/Pathoschild/SMAPI/releases/download/${SMAPI_VERSION}/SMAPI-${SMAPI_VERSION}-installer.zip" \
                    -o /opt/smapi/smapi.zip \
                && echo "SMAPI ${SMAPI_VERSION} downloaded to /opt/smapi"

# Pre-download compatible server mods to /opt/stardew-mods
# These are sourced from the puppy-stardew-server project (tested with 1.6.15)
RUN             mkdir -p /opt/stardew-mods

# Prepare X11 directory
RUN             mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Fix permissions
RUN             chown -R 1000:1000 /opt/smapi /opt/stardew-mods

# Environment
ENV             HOME=/home/container
ENV             DISPLAY=:99

COPY            entrypoint.sh /entrypoint.sh
RUN             chmod +x /entrypoint.sh

USER            1000:1000
WORKDIR         /home/container

CMD             ["/bin/bash", "/entrypoint.sh"]
