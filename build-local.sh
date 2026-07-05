#!/bin/bash
# WeatherGround iOS 12 Local Build Script
# For iPad mini 2 and iOS 12 compatible devices
# Usage: chmod +x build-local.sh && ./build-local.sh

set -e

echo "========================================"
echo "WeatherGround iOS 12 Build Script"
echo "========================================"
echo ""

# Check if Theos is installed
if [ -z "$THEOS" ]; then
    echo "❌ Error: THEOS environment variable not set"
    echo "Please install Theos: https://github.com/theos/theos"
    echo ""
    echo "Quick setup:"
    echo "  git clone --depth=1 https://github.com/theos/theos.git ~/theos"
    echo "  export THEOS=~/theos"
    echo "  echo 'export THEOS=~/theos' >> ~/.bashrc"
    exit 1
fi

echo "✓ Theos detected at: $THEOS"
echo ""

# Verify iOS SDK exists
if [ ! -d "$THEOS/sdks/iPhoneOS12.2.sdk" ]; then
    echo "⚠ Warning: iOS 12.2 SDK not found"
    echo "Location checked: $THEOS/sdks/iPhoneOS12.2.sdk"
    echo ""
    echo "To fix:"
    echo "1. Download iOS 12.2 SDK from https://github.com/theos/sdks"
    echo "2. Extract to: $THEOS/sdks/"
    echo "3. Try building again"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✓ iOS 12.2 SDK found"
    echo ""
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Building WeatherGround..."
echo "Project directory: $PROJECT_DIR"
echo ""

# Step 1: Clean
echo "[1/4] Cleaning previous builds..."
make clean 2>/dev/null || true
echo "✓ Clean complete"
echo ""

# Step 2: Build
echo "[2/4] Compiling tweak..."
if ! make FINALPACKAGE=1; then
    echo "❌ Build failed - check errors above"
    exit 1
fi
echo "✓ Compilation successful"
echo ""

# Step 3: Verify
echo "[3/4] Verifying build..."
if [ ! -d "packages" ]; then
    echo "❌ No packages directory created"
    exit 1
fi
echo "✓ Packages directory verified"
echo ""

# Step 4: Locate package
echo "[4/4] Locating package..."
DEB_FILE=$(find packages -name "*.deb" -type f | head -1)

if [ -z "$DEB_FILE" ]; then
    echo "❌ No .deb file found in packages directory"
    exit 1
fi

DEB_SIZE=$(du -h "$DEB_FILE" | cut -f1)
DEB_SHA=$(sha256sum "$DEB_FILE" | cut -d' ' -f1)
DEB_NAME=$(basename "$DEB_FILE")

echo "✓ Package located: $DEB_NAME"
echo ""

echo "========================================"
echo "✓ BUILD SUCCESSFUL!"
echo "========================================"
echo ""
echo "Package Information:"
echo "  File: $DEB_FILE"
echo "  Name: $DEB_NAME"
echo "  Size: $DEB_SIZE"
echo "  SHA256: $DEB_SHA"
echo ""
echo "Next steps:"
echo ""
echo "Option 1: Automatic SSH Installation"
echo "  chmod +x scripts/install-remote.sh"
echo "  ./scripts/install-remote.sh 192.168.1.100"
echo ""
echo "Option 2: Manual Installation"
echo "  scp $DEB_FILE root@192.168.1.100:/tmp/"
echo "  ssh root@192.168.1.100"
echo "  dpkg -i /tmp/$DEB_NAME"
echo "  uicache"
echo ""
echo "Option 3: Transfer via USB"
echo "  Use iFunBox or similar tool to place $DEB_NAME in /tmp/"
echo "  Then run: dpkg -i /tmp/$DEB_NAME && uicache"
echo ""
