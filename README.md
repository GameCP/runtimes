# GameCP Runtimes

Custom Docker images for game servers. Pre-bake Wine prefixes, dependencies, and runtime configs so game startup is instant.

## Images

| Image | Tag | Description | Used By |
|-------|-----|-------------|---------|
| `wine-base` | `ghcr.io/gamecp/runtimes:wine-base` | Wine + Mono + Xvfb, pre-initialized prefix | Base for all Wine games |
| `wine-vcrun` | `ghcr.io/gamecp/runtimes:wine-vcrun` | wine-base + vcrun2022 (VC++ runtime) | Subsistence, UE games |

## Why?

The generic `ptero-eggs/yolks:wine_latest` image requires Wine prefix setup at runtime:
- wineboot initialization (~2 min)
- Mono download + install (~5 min)
- winetricks vcrun2022 (~2 min)
- Multiple xvfb-run calls that leave stale X11 state

Our images bake all of this into the Docker image at build time. Game startup becomes:
1. Pull image (cached after first pull)
2. SteamCMD installs game files
3. Run the game executable

## Building

```bash
# Build wine-base first
docker build -t ghcr.io/gamecp/runtimes:wine-base ./wine-base/

# Build wine-vcrun (extends wine-base)
docker build -t ghcr.io/gamecp/runtimes:wine-vcrun ./wine-vcrun/
```

## Publishing

```bash
# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Push
docker push ghcr.io/gamecp/runtimes:wine-base
docker push ghcr.io/gamecp/runtimes:wine-vcrun
```

## Adding a New Runtime

1. Create a new directory: `runtimes/your-runtime/`
2. Add a `Dockerfile` (extend `wine-base` or `ghcr.io/parkervcp/yolks:debian`)
3. Build and test locally
4. Push to GHCR

## Architecture

```
runtimes/
  wine-base/        <- Wine + Mono + Xvfb (shared base)
    Dockerfile
    entrypoint.sh
  wine-vcrun/       <- wine-base + vcrun2022
    Dockerfile
```

The entrypoint handles:
- Starting Xvfb once (persistent display :0)
- Running additional winetricks from `WINETRICKS_RUN` env (if needed)
- Executing the game's `STARTUP` command
