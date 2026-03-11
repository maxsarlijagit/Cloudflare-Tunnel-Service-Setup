#!/usr/bin/env bash

# =========================================
# Cloudflare Tunnel Service Setup
# =========================================
#
# Installs a persistent systemd service for
# an existing Cloudflare Tunnel configuration.
#
# Requirements:
#   - cloudflared installed
#   - tunnel already authenticated
#   - ~/.cloudflared containing:
#        config.yml
#        <tunnel-id>.json
#
# Tested on:
#   AlmaLinux / RHEL / Ubuntu / Debian
#
# =========================================

set -euo pipefail

echo "======================================="
echo " Cloudflare Tunnel Service Setup"
echo "======================================="

USER_HOME=$(eval echo "~$USER")
CF_HOME="$USER_HOME/.cloudflared"
CF_ETC="/etc/cloudflared"

echo ""
echo "Scanning Cloudflare config in:"
echo "$CF_HOME"
echo ""

# ----------------------------------------
# Validate directory
# ----------------------------------------

if [[ ! -d "$CF_HOME" ]]; then
  echo "ERROR: Directory not found -> $CF_HOME"
  exit 1
fi

CONFIG_FILE="$CF_HOME/config.yml"
TUNNEL_JSON=$(ls "$CF_HOME"/*.json 2>/dev/null | head -n 1)

# ----------------------------------------
# Validate files
# ----------------------------------------

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: config.yml not found in $CF_HOME"
  exit 1
fi

if [[ -z "$TUNNEL_JSON" ]]; then
  echo "ERROR: No tunnel credential (.json) found in $CF_HOME"
  exit 1
fi

echo "Config file detected:"
echo "  $CONFIG_FILE"

echo ""
echo "Tunnel credential detected:"
echo "  $TUNNEL_JSON"

# ----------------------------------------
# Prepare /etc/cloudflared
# ----------------------------------------

echo ""
echo "Creating system config directory..."

sudo mkdir -p "$CF_ETC"

# ----------------------------------------
# Copy files
# ----------------------------------------

echo ""
echo "Copying configuration files..."

sudo cp "$CONFIG_FILE" "$CF_ETC/config.yml"
sudo cp "$TUNNEL_JSON" "$CF_ETC/"

TUNNEL_JSON_NAME=$(basename "$TUNNEL_JSON")

# ----------------------------------------
# Update credential path
# ----------------------------------------

echo ""
echo "Updating credentials path inside config.yml..."

sudo sed -i "s|credentials-file:.*|credentials-file: $CF_ETC/$TUNNEL_JSON_NAME|" "$CF_ETC/config.yml"

# ----------------------------------------
# Install systemd service
# ----------------------------------------

echo ""
echo "Installing cloudflared service..."

sudo cloudflared service install

# ----------------------------------------
# Reload systemd
# ----------------------------------------

echo ""
echo "Reloading systemd..."

sudo systemctl daemon-reload

# ----------------------------------------
# Enable service
# ----------------------------------------

echo ""
echo "Enabling service on boot..."

sudo systemctl enable cloudflared

# ----------------------------------------
# Start service
# ----------------------------------------

echo ""
echo "Starting service..."

sudo systemctl start cloudflared

# ----------------------------------------
# Status
# ----------------------------------------

echo ""
echo "Service status:"
echo "---------------------------------------"

systemctl status cloudflared --no-pager

echo ""
echo "======================================="
echo " Cloudflare Tunnel is active"
echo " and will start on boot"
echo "======================================="
