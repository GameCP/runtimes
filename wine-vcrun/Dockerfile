# -----------------------------------------------
# GameCP Wine + vcrun2022 Runtime
# For UDK/Unreal Engine games that need VC++ runtime
# Used by: Subsistence, and other UE games
# -----------------------------------------------
FROM            ghcr.io/gamecp/runtimes:wine-base

LABEL           maintainer="GameCP Team"

USER            root

# Install vcrun2022 into the pre-built Wine prefix
COPY            setup-vcrun.sh /tmp/setup-vcrun.sh
RUN             chmod +x /tmp/setup-vcrun.sh && /tmp/setup-vcrun.sh && rm /tmp/setup-vcrun.sh
RUN             chown -R 1000:1000 /home/container

USER            1000:1000
WORKDIR         /home/container

CMD             ["/bin/bash", "/entrypoint.sh"]
