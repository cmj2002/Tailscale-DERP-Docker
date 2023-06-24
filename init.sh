#!/bin/bash

# exit when any command fails
set -e

# create a tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# get comma separated list of arg $TAILSCALE_ARGS and convert to array
IFS=',' read -r -a TAILSCALE_ARGS <<< "$TAILSCALE_ARGS"

#Start tailscaled and connect to tailnet
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state >> /dev/stdout &

# sleep to wait for the daemon to start, default 2 seconds
sleep "$TAILSCALE_SLEEP"

/usr/bin/tailscale up --authkey="$TAILSCALE_AUTHKEY" "${TAILSCALE_ARGS[@]}" >> /dev/stdout &

# sleep to wait for the daemon to start, default 2 seconds
sleep "$TAILSCALE_SLEEP"

/app/derper --hostname="$DERP_DOMAIN" \
    --certmode="$DERP_CERT_MODE" \
    --certdir="$DERP_CERT_DIR" \
    --a="$DERP_ADDR" \
    --stun="$DERP_STUN"  \
    --http-port="$DERP_HTTP_PORT" \
    --verify-clients=true\
