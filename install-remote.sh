#!/bin/bash
# WeatherGround iOS 12 Remote Installation Script
# Installs the built tweak to a remote iOS device via SSH
# Usage: chmod +x install-remote.sh && ./install-remote.sh 192.168.1.100

set -e

DEVICE_IP="$1"
SSH_PORT="${2:-22}"

if [ -z "$DEVICE_IP" ]; then
    echo "Usage: $0 <device-ip> [ssh-port]"
    echo "Example: $0 192.168.1.100 22"
    exit 1
fi

echo "========================================"
echo "WeatherGround Remote Installation"
echo "========================================"
echo "Device: $DEVICE_IP:$SSH_PORT"
echo ""

# Find the DEB file
DEB_FILE=$(find . -name "*.deb" -type f | head -1)

if [ -z "$DEB_FILE" ]; then
    echo "❌ No .deb file found"
    echo "Please run ./build-local.sh first"
    exit 1
fi

DEB_NAME=$(basename "$DEB_FILE")
DEB_SIZE=$(du -h "$DEB_FILE" | cut -f1)

echo "Package: $DEB_FILE"
echo "Size: $DEB_SIZE"
echo ""

# Test SSH connection
echo "[1/5] Testing SSH connection..."
if ! ssh -p $SSH_PORT root@$DEVICE_IP "echo 'Connected'" > /dev/null 2>&1; then
    echo "❌ Could not connect to device via SSH"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Ensure device is on same network"
    echo "  2. Enable SSH in Cydia Settings"
    echo "  3. Verify IP address is correct"
    echo "  4. Check firewall allows port 22"
    exit 1
fi
echo "✓ SSH connection successful"
echo ""

# Copy package to device
echo "[2/5] Copying package to device..."
scp -P $SSH_PORT "$DEB_FILE" root@$DEVICE_IP:/tmp/
echo "✓ Package copied"
echo ""

# Install package
echo "[3/5] Installing package..."
ssh -p $SSH_PORT root@$DEVICE_IP "dpkg -i /tmp/$DEB_NAME"
echo "✓ Package installed"
echo ""

# Run uicache
echo "[4/5] Updating UI cache..."
ssh -p $SSH_PORT root@$DEVICE_IP "uicache"
echo "✓ UI cache updated"
echo ""

# Verify installation
echo "[5/5] Verifying installation..."
if ssh -p $SSH_PORT root@$DEVICE_IP "dpkg -l | grep -q com.tr1fecta.weatherground"; then
    echo "✓ Installation verified"
else
    echo "⚠ Installation verification inconclusive"
fi
echo ""

echo "========================================"
echo "✓ INSTALLATION COMPLETE!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Respring your device (or restart)"
echo "2. Go to Settings → WeatherGround"
echo "3. Enable the tweak and configure options"
echo ""
echo "To respring from CLI:"
echo "  ssh -p $SSH_PORT root@$DEVICE_IP 'killall -9 backboardd'"
echo ""
