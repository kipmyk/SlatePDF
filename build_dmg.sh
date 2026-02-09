#!/bin/bash

# SlatePDF Local DMG Build Script

APP_NAME="SlatePDF"
BUNDLE_ID="com.kipmyk.slatepdf"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}.dmg"
OUTPUT_DIR="dist"
APP_BUNDLE="${OUTPUT_DIR}/${APP_NAME}.app"

echo "🚀 Starting local build for ${APP_NAME}..."

# 1. Check for dependencies
if ! command -v create-dmg &> /dev/null; then
    echo "⚠️  create-dmg not found. Installing via Homebrew..."
    brew install create-dmg
fi

# 2. Clean and create output directory
rm -rf "${OUTPUT_DIR}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 3. Build the executable in release mode
echo "🔨 Building executable..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# 4. Copy the executable
EXECUTABLE_PATH=$(swift build -c release --show-bin-path)/${APP_NAME}
cp "${EXECUTABLE_PATH}" "${APP_BUNDLE}/Contents/MacOS/"

# 5. Create Info.plist
echo "📝 Creating Info.plist..."
cat > "${APP_BUNDLE}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 6. Create DMG
echo "📦 Packaging DMG..."
rm -f "${DMG_NAME}"

create-dmg \
  --volname "${APP_NAME}" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 185 \
  "${DMG_NAME}" \
  "${APP_BUNDLE}"

if [ $? -eq 0 ]; then
    echo "✅ Success! ${DMG_NAME} created in the current directory."
    echo "📂 Done! You can now open ${DMG_NAME} to install the app."
else
    echo "❌ DMG creation failed!"
    exit 1
fi
