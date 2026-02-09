#!/bin/bash
# Kill any running SlatePDF instances and restart

echo "🛑 Stopping any running SlatePDF instances..."
pkill -f "SlatePDF" 2>/dev/null

sleep 1

echo "🔨 Building SlatePDF..."
swift build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🚀 Launching SlatePDF..."
    .build/debug/SlatePDF
else
    echo "❌ Build failed"
    exit 1
fi
