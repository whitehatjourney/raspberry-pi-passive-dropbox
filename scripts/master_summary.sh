#!/usr/bin/env bash
# master_summary.sh
# Generates a quick dashboard-style summary of recent Drop Box activity,
# including capture service status, ARPWatch logs, and top network protocols.

OUT="/var/log/dropbox/summary_all.txt"
PCAPDIR="/var/log/dropbox/pcap"

echo "==== DROP BOX MASTER SUMMARY ====" > "$OUT"
echo "Generated: $(date)" >> "$OUT"
echo >> "$OUT"

echo "-- Capture Status --" >> "$OUT"
systemctl status dropbox-capture.service --no-pager >> "$OUT"
echo >> "$OUT"

echo "-- ARPWatch (Last 24h) --" >> "$OUT"
journalctl -u arpwatch --since "24 hours ago" --no-pager >> "$OUT"
echo >> "$OUT"

echo "-- Traffic Overview (Last 12h) --" >> "$OUT"
find "$PCAPDIR" -type f -name "*.pcap" -mmin -720 \
  -exec tshark -r {} -q 2>/dev/null \; | wc -l >> "$OUT"

echo >> "$OUT"
echo "-- Top Protocols --" >> "$OUT"
find "$PCAPDIR" -type f -name "*.pcap" -mmin -720 \
  -exec tshark -r {} -T fields -e _ws.col.Protocol 2>/dev/null \; \
  | sort | uniq -c | sort -nr | head -n 15 >> "$OUT"

echo >> "$OUT"
echo "==== END ====" >> "$OUT"
