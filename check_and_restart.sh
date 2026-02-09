#!/bin/bash

echo "🔍 Checking SlatePDF setup..."
echo ""

# Check if app is running
RUNNING=$(ps aux | grep -i slatepdf | grep -v grep | wc -l)
if [ $RUNNING -gt 0 ]; then
    echo "⚠️  SlatePDF is currently RUNNING (old version)"
    echo "   PID: $(ps aux | grep -i slatepdf | grep -v grep | awk '{print $2}')"
    echo "   Running since: $(ps aux | grep -i slatepdf | grep -v grep | awk '{print $9}')"
    echo ""
    echo "❌ You need to KILL the old version first!"
    echo ""
    read -p "Do you want me to kill it and restart? (y/n) " answer
    if [ "$answer" = "y" ]; then
        echo "🛑 Killing old version..."
        pkill -9 SlatePDF
        sleep 2
        echo "🔨 Building latest version..."
        swift build
        echo "🚀 Starting new version..."
        .build/debug/SlatePDF &
        echo ""
        echo "✅ New version launched!"
        echo "📝 Check the terminal output for debug messages when you click Edit Page"
    fi
else
    echo "✅ No SlatePDF running"
    echo ""
    echo "Building and starting..."
    swift build
    .build/debug/SlatePDF &
    echo ""
    echo "✅ App started!"
fi
