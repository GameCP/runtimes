# -----------------------------------------------
# GameCP Wine + vcrun2022 Runtime
# For UDK/Unreal Engine games that need VC++ runtime
# Used by: Subsistence, and other UE games
# -----------------------------------------------
FROM            ghcr.io/gamecp/runtimes:wine-base

LABEL           maintainer="GameCP Team"

USER            root

# Install vcrun2022 into the pre-built Wine prefix
# The vc_redist installer crashes but cabextract gets the DLLs we need
RUN             Xvfb :0 -screen 0 640x480x24 -ac & \
                && sleep 2 \
                && export WINEDLLOVERRIDES="mscoree,mshtml=" \
                && winetricks -q vcrun2022 || true \
                && wineserver -k || true \
                && chown -R 1000:1000 /home/container

USER            1000:1000
WORKDIR         /home/container

CMD             ["/bin/bash", "/entrypoint.sh"]
