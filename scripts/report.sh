#!/usr/bin/env bash
# report.sh
# Generates a 12-hour summary of captured PCAP files, including
# top protocols, top source/destination IPs, and ARP/DNS/DHCP counts.
set -euo pipefail

PCAPDIR="/var/log/dropbox/pcap"
OUTDIR="/var/log/dropbox/reports"
mkdir -p "$OUTDIR"

OUTFILE="${OUTDIR}/daily_$(date +%F).txt"

echo "==== Drop Box Daily Summary ($(date)) ====" >> "$OUTFILE"
echo "" >> "$OUTFILE"

# Count packets by simple protocol hints (ARP/DHCP/DNS) using tshark
echo "-- Packet counts (ARP/DHCP/DNS) --" >> "$OUTFILE"
tshark -r "${PCAPDIR}"/*.pcap -q -z io,phs 2>/dev/null | tail -n +1 >> "$OUTFILE" || true
echo "" >> "$OUTFILE"

# Top talkers by IP (very rough, but useful)
echo "-- Top source IPs (approx) --" >> "$OUTFILE"
tshark -r "${PCAPDIR}"/*.pcap -T fields -e ip.src 2>/dev/null \
  | grep -E '^[0-9]+\.' | sort | uniq -c | sort -nr | head -n 20 >> "$OUTFILE" || true
echo "" >> "$OUTFILE"

echo "-- Top destination IPs (approx) --" >> "$OUTFILE"
tshark -r "${PCAPDIR}"/*.pcap -T fields -e ip.dst 2>/dev/null \
  | grep -E '^[0-9]+\.' | sort | uniq -c | sort -nr | head -n 20 >> "$OUTFILE" || true
echo "" >> "$OUTFILE"

echo "==== End ====" >> "$OUTFILE"
echo "" >> "$OUTFILE"
