#!/usr/bin/env bash
set -euo pipefail

PCAPDIR="/var/log/dropbox/pcap"
OUTDIR="/var/log/dropbox/reports"
mkdir -p "$OUTDIR"
OUTFILE="${OUTDIR}/daily_$(date +%F).txt"

echo "==== Drop Box Daily Summary ($(date)) ====" >> "$OUTFILE"
echo "" >> "$OUTFILE"

mapfile -t PCAPFILES < <(ls -t "${PCAPDIR}"/*.pcap 2>/dev/null | head -n 13 | tail -n 12)

echo "-- Packet counts (ARP/DHCP/DNS/mDNS) --" >> "$OUTFILE"

ARP=0; DHCP=0; DNS=0; MDNS=0

if [ ${#PCAPFILES[@]} -gt 0 ]; then
  for f in "${PCAPFILES[@]}"; do
    ARP=$((ARP + $(/usr/bin/tshark -r "$f" -Y arp  2>/dev/null | wc -l)))
    DHCP=$((DHCP + $(/usr/bin/tshark -r "$f" -Y dhcp 2>/dev/null | wc -l)))
    DNS=$((DNS + $(/usr/bin/tshark -r "$f" -Y dns  2>/dev/null | wc -l)))
    MDNS=$((MDNS + $(/usr/bin/tshark -r "$f" -Y mdns 2>/dev/null | wc -l)))
  done
fi

echo "arp:  $ARP"  >> "$OUTFILE"
echo "dhcp: $DHCP" >> "$OUTFILE"
echo "dns:  $DNS"  >> "$OUTFILE"
echo "mdns: $MDNS" >> "$OUTFILE"
echo "" >> "$OUTFILE"

echo "==== End ====" >> "$OUTFILE"
echo "" >> "$OUTFILE"
