#!/bin/bash

output=$(/app/derpprobe --once --derp-map file:///derpmap.json 2>&1)
echo "$output" >&2

if [[ $output =~ good:\ derp/[^/]+/[^/]+/tls && $output =~ good:\ derp/[^/]+/[^/]+/udp ]]; then
  echo "healthcheck passed"
  exit 0
# for 2 fail reasons, print "<tls/udp> check failed"
elif [[ $output =~ bad:\ derp/[^/]+/[^/]+/tls ]]; then
  echo "tls check failed"
  exit 1
elif [[ $output =~ bad:\ derp/[^/]+/[^/]+/udp ]]; then
  echo "udp check failed"
  exit 1
else
  echo "healthcheck failed with unknown reason"
  exit 1
fi