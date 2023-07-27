#!/bin/bash

# exit when any command fails
set -e

# create a tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# get comma separated list of arg $TAILSCALE_ARGS and convert to array
IFS=',' read -r -a TAILSCALE_ARGS <<< "$TAILSCALE_ARGS"

if [ -f /var/lib/tailscale/tailscaled.state ]; then
    echo "Using existing state file. Skipping authkey."
    INITED=true
else
    echo "No state file found. Using authkey."
    INITED=false
    if [ -z "$TAILSCALE_AUTHKEY" ]; then
        echo "No authkey provided. Exiting."
        exit 1
    fi
fi

#Start tailscaled and connect to tailnet
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state >> /dev/stdout &

# sleep to wait for the daemon to start, default 2 seconds
sleep "$TAILSCALE_SLEEP"

if [ "$INITED" = false ] ; then
    /usr/bin/tailscale up --authkey="$TAILSCALE_AUTHKEY" "${TAILSCALE_ARGS[@]}" >> /dev/stdout &
else
    /usr/bin/tailscale up "${TAILSCALE_ARGS[@]}" >> /dev/stdout &
fi

# sleep to wait for the daemon to start, default 2 seconds
sleep "$TAILSCALE_SLEEP"

/app/derper --hostname="$DERP_DOMAIN" \
    --certmode="$DERP_CERT_MODE" \
    --certdir="$DERP_CERT_DIR" \
    --a="$DERP_ADDR" \
    --stun="$DERP_STUN"  \
    --http-port="$DERP_HTTP_PORT" \
    --verify-clients=true\
