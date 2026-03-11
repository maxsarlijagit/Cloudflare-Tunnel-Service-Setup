# Cloudflare Tunnel Service Setup

Script to install a persistent systemd service for an existing Cloudflare Tunnel.

## Requirements

- cloudflared installed
- authenticated tunnel
- ~/.cloudflared containing:

config.yml
tunnel-id.json

## Usage

chmod +x setup-cloudflare-service.sh

./setup-cloudflare-service.sh

## Result

Installs a systemd service:

systemctl status cloudflared

Tunnel will start automatically on boot.
