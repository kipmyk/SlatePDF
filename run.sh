#!/bin/bash
# SlatePDF Launcher Script

echo "🚀 Building SlatePDF..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🎨 Launching SlatePDF..."
    .build/release/SlatePDF
else
    echo "❌ Build failed"
    exit 1
fi
