# -----------------------------------------------
# GameCP Wine Base Runtime
# Pre-bakes Wine prefix + Mono at /opt/wine-prefix
# so it survives volume mounts at /home/container.
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
                && apt install --install-recommends winehq-stable wine-binfmt cabextract -y \
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

# Prepare directories
RUN             mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix \
                && mkdir -p /home/container/.wine /home/container/.cache \
                && mkdir -p /opt/wine-prefix

# Pre-initialize Wine prefix + Mono, saved to /opt/wine-prefix
COPY            setup-prefix.sh /tmp/setup-prefix.sh
RUN             chmod +x /tmp/setup-prefix.sh && /tmp/setup-prefix.sh && rm /tmp/setup-prefix.sh

# Fix permissions
RUN             chown -R 1000:1000 /home/container /opt/wine-prefix /opt/wine-cache

# Environment
ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine
ENV             WINEDEBUG=-all
ENV             DISPLAY=:0

COPY            entrypoint.sh /entrypoint.sh
RUN             chmod +x /entrypoint.sh

USER            1000:1000
WORKDIR         /home/container

CMD             ["/bin/bash", "/entrypoint.sh"]
