#!/bin/bash
# FinGuard DuckDNS Updater Script
# Usage: ./duckdns-update.sh [DUCKDNS_TOKEN] [DOMAIN]

DOMAIN="${2:-${DUCKDNS_DOMAIN:-finguarddd}}"
TOKEN="${1:-${DUCKDNS_TOKEN}}"

if [ -z "$TOKEN" ]; then
    echo "Usage: $0 <DUCKDNS_TOKEN> [DOMAIN]"
    echo "Or export DUCKDNS_TOKEN='your-token' and run $0"
    exit 1
fi

echo "Updating DuckDNS for ${DOMAIN}.duckdns.org..."
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=")
echo "DuckDNS response: $RESPONSE"

if [ "$RESPONSE" = "OK" ]; then
    echo "Successfully updated ${DOMAIN}.duckdns.org to current public IP."
else
    echo "DuckDNS update failed. Please check your token."
fi
