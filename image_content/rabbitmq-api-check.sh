#!/bin/sh

set -e
URL="http://guest:guest@127.0.0.1:15672/api/healthchecks/node"
EXPECTED='{"status":"ok"}'
ACTUAL=$(curl --silent --show-error --fail "${URL}")
echo "${ACTUAL}"
test "${EXPECTED}" = "${ACTUAL}"