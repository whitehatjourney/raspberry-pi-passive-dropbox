#!/usr/bin/env bash
set -euo pipefail

# Pick the interface that has the default route (works for wlan0 now, eth0 later)
IFACE="$(ip route show default 0.0.0.0/0 | awk '{print $5; exit}')"
if [[ -z "${IFACE}" ]]; then
  echo "No default route found; cannot determine interface." >&2
  exit 1
fi

OUTDIR="/var/log/dropbox/pcap"
mkdir -p "$OUTDIR"

# Rotate: one file every 10 minutes, keep 72 files (~12 hours). Adjust later if you want longer retention.
# -nn: no name resolution (stealthier + faster)
# -s 0: full packet capture
exec tcpdump -i "$IFACE" -nn -s 0 \
  -w "${OUTDIR}/capture_%Y-%m-%d_%H-%M-%S.pcap" \
  -G 600 -W 72
