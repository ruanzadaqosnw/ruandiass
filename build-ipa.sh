#!/bin/bash

# Build IPA Script for IPA API Server
# Usage: ./build-ipa.sh

set -e

PROJECT_NAME="IPAAPIServer"
SCHEME="IPAAPIServer"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/IPA"

echo "🔨 Building IPA for $PROJECT_NAME..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build archive
echo "📦 Creating archive..."
xcodebuild archive \
  -scheme "$SCHEME" \
  -archivePath "$ARCHIVE_PATH" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  -verbose

# Create export options plist
echo "⚙️  Creating export options..."
cat > "$BUILD_DIR/ExportOptions.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>REPLACE_WITH_YOUR_TEAM_ID</string>
</dict>
</plist>
EOF

# Export IPA
echo "📤 Exporting IPA..."
mkdir -p "$EXPORT_PATH"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  -exportPath "$EXPORT_PATH" \
  -verbose

# Find the generated IPA
IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -1)

if [ -f "$IPA_FILE" ]; then
    echo "✅ IPA generated successfully!"
    echo "📍 Location: $IPA_FILE"
    echo ""
    echo "📝 Next steps:"
    echo "1. Sign the IPA with your certificate:"
    echo "   codesign -fs 'YOUR_CERTIFICATE_NAME' '$IPA_FILE'"
    echo ""
    echo "2. Install on device using Xcode or ios-deploy:"
    echo "   ios-deploy -b '$IPA_FILE'"
    echo ""
    echo "3. Or use Apple Configurator 2 to install on your iPhone"
else
    echo "❌ Failed to generate IPA"
    exit 1
fi
