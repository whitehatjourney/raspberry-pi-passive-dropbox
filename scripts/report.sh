#!/usr/bin/env bash
# report.sh
# Generates a 12-hour summary of captured PCAP files, including
# top protocols, top source/destination IPs, and ARP/DNS/DHCP counts.
set -euo pipefail

PCAPDIR="/var/log/dropbox/pcap"
OUTDIR="/var/log/dropbox/reports"
mkdir -p "$OUTDIR"

TS="$(date +%F_%H%M)"
OUTFILE="${OUTDIR}/summary_${TS}.txt"

mapfile -t pcaps < <(find "$PCAPDIR" -type f -name "*.pcap" -mmin -720 2>/dev/null | sort)

{
  echo "==== Drop Box Summary (Last 12 Hours) ===="
  echo "Generated: $(date)"
  echo "PCAP files included: ${#pcaps[@]}"
  echo
} >> "$OUTFILE"

if (( ${#pcaps[@]} == 0 )); then
  echo "No PCAP files found." >> "$OUTFILE"
  exit 0
fi

{
  echo "-- Total Packet Count (approx lines read) --"
  tshark -r "${pcaps[@]}" -q 2>/dev/null | wc -l
  echo

  echo "-- Top Protocols --"
  tshark -r "${pcaps[@]}" -T fields -e _ws.col.Protocol 2>/dev/null \
    | sort | uniq -c | sort -nr | head -n 15
  echo

  echo "-- Top Source IPs --"
  tshark -r "${pcaps[@]}" -T fields -e ip.src 2>/dev/null \
    | grep -E '^[0-9]+\.' | sort | uniq -c | sort -nr | head -n 15
  echo

  echo "-- Top Destination IPs --"
  tshark -r "${pcaps[@]}" -T fields -e ip.dst 2>/dev/null \
    | grep -E '^[0-9]+\.' | sort | uniq -c | sort -nr | head -n 15
  echo

  echo "-- ARP / DNS / DHCP Counts --"
  echo "ARP:   $(tshark -r "${pcaps[@]}" -Y arp   -q 2>/dev/null | wc -l)"
  echo "DNS:   $(tshark -r "${pcaps[@]}" -Y dns   -q 2>/dev/null | wc -l)"
  echo "DHCP:  $(tshark -r "${pcaps[@]}" -Y bootp -q 2>/dev/null | wc -l)"
  echo

  echo "==== End ===="
} >> "$OUTFILE"

echo "Wrote: $OUTFILE"
