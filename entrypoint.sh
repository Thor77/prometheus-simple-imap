#!/bin/bash
set -euo pipefail

touch /tmp/metrics
miniserve --index /tmp/metrics &

/usr/local/bin/update-metrics.sh

crond -f -l 1
