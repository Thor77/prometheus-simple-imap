#!/bin/bash
set -euo pipefail

touch /tmp/metrics

# serve metrics on all paths
miniserve --spa --index /tmp/metrics &

/usr/local/bin/update-metrics.sh

crond -f -l 1
