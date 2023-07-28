Customized version of [tijjjy/Tailscale-DERP-Docker](https://github.com/tijjjy/Tailscale-DERP-Docker).

Changes:
- Reduce the size of the image through multi-stage builds (v2.0)
- Use reverse proxy instead of letting derp handle certificates (in order to avoid occupying port 443 of host) (v2.0)
- Avoid using the TUN device of the host, instead create a TUN device in the container (v2.0)
- Avoid granting the container `NET_RAW` permission (v2.0)
- Allow passing custom arguments to `tailscale` via environment variable `TAILSCALE_ARGS` (v2.0)
- If it's not the first run of the container (`tailscaled.state` exists), it will not use auth key (v3.0)
- Add healthcheck (v3.0)

Notes:
- You might find `v1.0` tag of image. It's a legacy version which I use before (not built from @tijjjy's repo). It's not recommended to use it.
- The image is built for amd64 only. If you want to use it on other architectures, you need to build it yourself.
- If your server's performance is too low, you may need to adjust TAILSCALE_SLEEP so that tailscaled has more time to start.
- If you want to use healthcheck and wondering how to write `derpmap.json`, use [this](https://login.tailscale.com/derpmap/default) as a example. You don't need to include official nodes, just include your custom derper.
- I did not enable the mesh functionality of derper (because I only deployed one derper), so it is normal for `derpprobe` to show that the mesh detection failed.
