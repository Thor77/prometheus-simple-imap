#!/bin/bash
set -euo pipefail

source /config

# verify env settings
if [[ -z "${IMAP_USERNAME:-}" || -z "${IMAP_PASSWORD:-}" || -z "${IMAP_HOST:-}" ]]; then
    echo "missing envvars" >/dev/stderr
    exit 1
fi

tmpfile="$(mktemp)"
echo "
poll $IMAP_HOST protocol IMAP
  user \"$IMAP_USERNAME\" password \"$IMAP_PASSWORD\"
  ssl
  folder INBOX
  keep
" > "$tmpfile"
output="$(fetchmail -c -f "$tmpfile")"
rm "$tmpfile"

if [[ -z "$output" ]]; then
    echo "fetchmail execution failed" >/dev/stderr
    exit 1
fi
total=$(echo "$output" | sed -n 's/.*fetchmail: \([0-9]*\) messages.*/\1/p')
seen=$(echo "$output" | sed -n 's/.*(\([0-9]*\) seen).*/\1/p')
unseen=$((total - seen))

metrics_tmp="$(mktemp)"
echo "imap_messages_total $total
imap_messages_seen $seen
imap_messages_unseen $unseen" > "$metrics_tmp"
mv "$metrics_tmp" /tmp/metrics
