#!/bin/sh
set -e

# Train models if they do not exist
if [ ! -f "models/supervised.pkl" ] || [ ! -f "models/scaler.pkl" ]; then
    echo "[FinGuard] Pre-trained models not found in models/. Generating data and training..."
    python data/generator.py
    python src/train.py
    echo "[FinGuard] Model training complete."
fi

# Optional DuckDNS updater background service
if [ -n "$DUCKDNS_TOKEN" ]; then
    DOMAIN="${DUCKDNS_DOMAIN:-finguarddd}"
    echo "[DuckDNS] Starting periodic DNS update for ${DOMAIN}.duckdns.org..."
    (
        while true; do
            TS=$(date '+%Y-%m-%d %H:%M:%S')
            RESP=$(curl -s "https://www.duckdns.org/update?domains=${DOMAIN}&token=${DUCKDNS_TOKEN}&ip=")
            echo "[DuckDNS $TS] Domain: ${DOMAIN}.duckdns.org, status: ${RESP}"
            sleep 300
        done
    ) &
fi

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"

echo "=========================================================="
echo " FinGuard All-in-One is ready!"
echo " Serving Frontend & Backend on: http://${HOST}:${PORT}"
echo " Accessible via DuckDNS: http://${DUCKDNS_DOMAIN:-finguarddd}.duckdns.org"
echo " API Documentation: http://${HOST}:${PORT}/docs"
echo "=========================================================="

exec uvicorn api.main:app --host "${HOST}" --port "${PORT}"
