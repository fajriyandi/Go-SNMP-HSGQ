#!/bin/bash
# HSGQ OLT API - startup script
# Reads config from .env file

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY="$SCRIPT_DIR/hsgq"

if [ ! -f "$BINARY" ]; then
    echo "Error: binary hsgq not found!"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "Error: .env file not found!"
    echo "Copy env.example to .env and fill in your values."
    exit 1
fi

echo "Starting HSGQ OLT API..."
exec "$BINARY"
