#!/usr/bin/env bash
# export_all.sh
# Creates a single consolidated export file containing capture service status,
# ARPWatch logs, summary reports, and protocol statistics.
set -euo pipefail

USER_HOME="/home/jessiehacks"   # <-- change if your username differs
OUT="${USER_HOME}/dropbox_export_$(date +%F_%H%M).txt"
PCAPDIR="/var/log/dropbox/pcap"
REPORTDIR="/var/log/dropbox/reports"

{
  echo "==== DROP BOX FULL EXPORT ===="
  echo "Generated: $(date)"
  echo

  echo "==== CAPTURE SERVICE STATUS ===="
  systemctl status dropbox-capture.service --no-pager || true
  echo

  echo "==== CAPTURE SERVICE RESTART STATS ===="
  systemctl show dropbox-capture.service -p ActiveEnterTimestamp -p ExecMainStatus -p NRestarts || true
  echo

  echo "==== ARPWATCH (LAST 24H) ===="
  journalctl -u arpwatch --since "24 hours ago" --no-pager || true
  echo

  echo "==== LATEST SUMMARY REPORT (if present) ===="
  if ls -1 "$REPORTDIR" >/dev/null 2>&1; then
    latest="$(ls -t "$REPORTDIR" | head -n 1 || true)"
    if [[ -n "${latest:-}" ]]; then
      echo "-- File: $REPORTDIR/$latest"
      cat "$REPORTDIR/$latest" || true
    else
      echo "No report files found in $REPORTDIR"
    fi
  else
    echo "Report directory not found: $REPORTDIR"
  fi
  echo

  echo "==== PCAP WINDOW (oldest/newest) ===="
  if ls -1 "$PCAPDIR"/*.pcap >/dev/null 2>&1; then
    echo "Oldest: $(ls -1 "$PCAPDIR"/*.pcap | head -n 1)"
    echo "Newest: $(ls -1 "$PCAPDIR"/*.pcap | tail -n 1)"
  else
    echo "No PCAPs found in $PCAPDIR"
  fi
  echo

  echo "==== TOP PROTOCOLS (LAST 12H) ===="
  find "$PCAPDIR" -type f -name "*.pcap" -mmin -720 \
    -exec tshark -r {} -T fields -e _ws.col.Protocol 2>/dev/null \; \
    | sort | uniq -c | sort -nr | head -n 20 || true

  echo
  echo "==== END ===="
} > "$OUT"

echo "Export saved to: $OUT"
