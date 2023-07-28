FROM golang:latest AS builder
WORKDIR /app

# https://tailscale.com/kb/1118/custom-derp-servers/
RUN go install tailscale.com/cmd/derper@main

# use for healthcheck
RUN go install tailscale.com/cmd/derpprobe@latest

FROM ubuntu:jammy
WORKDIR /app

LABEL org.opencontainers.image.source https://github.com/cmj2002/Tailscale-DERP-Docker

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y ca-certificates curl && \
    apt-get clean

RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list

RUN apt-get update && \
    apt-get install -y tailscale && \
    apt-get clean

RUN mkdir /app/certs

ENV DERP_DOMAIN your-hostname.com
ENV DERP_CERT_MODE letsencrypt
ENV DERP_CERT_DIR /app/certs
ENV DERP_ADDR :443
ENV DERP_STUN true
ENV DERP_HTTP_PORT 80
ENV TAILSCALE_SLEEP 2

COPY --from=builder /go/bin/derper .
COPY --from=builder /go/bin/derpprobe .

COPY init.sh /init.sh
COPY health.sh /health.sh
RUN chmod +x /init.sh
RUN chmod +x /health.sh

ENTRYPOINT /init.sh