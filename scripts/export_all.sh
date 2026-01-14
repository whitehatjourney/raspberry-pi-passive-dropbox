#!/usr/bin/env bash
# export_all.sh
# Creates a single consolidated export file containing capture service status,
# ARPWatch logs, summary reports, and protocol statistics.

OUT="$HOME/dropbox_export_$(date +%F_%H%M).txt"
PCAPDIR="/var/log/dropbox/pcap"
REPORTDIR="/var/log/dropbox/reports"

echo "==== DROP BOX FULL EXPORT ====" > "$OUT"
echo "Generated: $(date)" >> "$OUT"
echo >> "$OUT"

echo "==== CAPTURE SERVICE STATUS ====" >> "$OUT"
systemctl status dropbox-capture.service --no-pager >> "$OUT"
echo >> "$OUT"

echo "==== ARPWATCH (LAST 24H) ====" >> "$OUT"
journalctl -u arpwatch --since "24 hours ago" --no-pager >> "$OUT"
echo >> "$OUT"

echo "==== LATEST SUMMARY REPORT ====" >> "$OUT"
ls -t "$REPORTDIR" | head -n 1 | xargs -I{} cat "$REPORTDIR/{}" >> "$OUT"
echo >> "$OUT"

echo "==== BASIC TRAFFIC STATS (LAST 12H) ====" >> "$OUT"
find "$PCAPDIR" -type f -name "*.pcap" -mmin -720 \
  -exec tshark -r {} -q 2>/dev/null \; | wc -l >> "$OUT"

echo >> "$OUT"
echo "==== TOP PROTOCOLS ====" >> "$OUT"
find "$PCAPDIR" -type f -name "*.pcap" -mmin -720 \
  -exec tshark -r {} -T fields -e _ws.col.Protocol 2>/dev/null \; \
  | sort | uniq -c | sort -nr | head -n 20 >> "$OUT"

echo >> "$OUT"
echo "==== END ====" >> "$OUT"

echo "Export saved to: $OUT"
