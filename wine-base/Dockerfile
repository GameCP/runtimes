# -----------------------------------------------
# GameCP Wine Base Runtime
# Pre-bakes Wine prefix, Mono, and Xvfb so game
# startup scripts don't need to handle X11 setup.
# -----------------------------------------------
FROM            ghcr.io/parkervcp/yolks:debian

LABEL           maintainer="GameCP Team"
LABEL           org.opencontainers.image.source="https://github.com/gamecp/runtimes"
LABEL           org.opencontainers.image.licenses=MIT

# Install Wine + X11 dependencies
RUN             dpkg --add-architecture i386 \
                && apt update -y \
                && apt install -y --no-install-recommends \
                    gnupg2 \
                    tzdata \
                    software-properties-common \
                    libntlm0 \
                    winbind \
                    xvfb \
                    xauth \
                    python3 \
                    cabextract \
                    libncurses5:i386 \
                    libncurses6:i386 \
                    libsdl2-2.0-0 \
                    libsdl2-2.0-0:i386 \
                && rm -rf /var/lib/apt/lists/*

# Install Wine stable
RUN             mkdir -pm755 /etc/apt/keyrings \
                && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
                && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
                && apt update \
                && apt install --install-recommends winehq-stable wine-binfmt -y \
                && rm -rf /var/lib/apt/lists/*

# Install rcon-cli
RUN             cd /tmp/ \
                && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
                && tar xvf rcon.tar.gz \
                && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/ \
                && rm -rf /tmp/*

# Install winetricks
RUN             wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/pelican-eggs/winetricks/master/src/winetricks \
                && chmod +x /usr/sbin/winetricks

# Create /tmp/.X11-unix as root (before we drop privileges)
RUN             mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Environment
ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine
ENV             WINEDEBUG=-all
ENV             DISPLAY=:0

# Pre-initialize Wine prefix as root, then fix permissions
# This creates a working prefix with Mono so games don't need to do it at runtime
RUN             mkdir -p /home/container/.wine \
                && mkdir -p /home/container/.cache \
                && Xvfb :0 -screen 0 640x480x24 -ac &\
                && sleep 2 \
                && WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init \
                && sleep 5 \
                # Download and install Wine Mono
                && MONO_VER=9.4.0 \
                && wget -q -O /home/container/.cache/wine-mono-${MONO_VER}-x86.msi \
                    https://dl.winehq.org/wine/wine-mono/${MONO_VER}/wine-mono-${MONO_VER}-x86.msi \
                && wine msiexec /i /home/container/.cache/wine-mono-${MONO_VER}-x86.msi /qn \
                && sleep 2 \
                && wineserver -k || true \
                && chown -R 1000:1000 /home/container

COPY            entrypoint.sh /entrypoint.sh
RUN             chmod +x /entrypoint.sh

USER            1000:1000
WORKDIR         /home/container

CMD             ["/bin/bash", "/entrypoint.sh"]
