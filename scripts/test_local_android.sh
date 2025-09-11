#!/bin/bash

# Android integration test runner for macOS
# This script runs the integration tests on Android emulator

set -e

echo "=== AI Edge Android Integration Test Runner ==="
echo

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MODEL_DIR="$PROJECT_ROOT/.models"

# Download model if needed
echo "📥 Checking for test model..."
mkdir -p "$MODEL_DIR"
./scripts/download_test_model.sh "$MODEL_DIR"

# Get model path
source "$PROJECT_ROOT/.github/workflows/model.env"
MODEL_PATH="$MODEL_DIR/$MODEL_FILE"

if [ ! -f "$MODEL_PATH" ]; then
  echo "❌ Model file not found at: $MODEL_PATH"
  exit 1
fi

echo "✅ Model found at: $MODEL_PATH"
echo "   Size: $(ls -lh $MODEL_PATH | awk '{print $5}')"
echo

echo "🤖 Running Android tests on macOS..."

# Make sure an emulator is running
if ! adb devices | grep -q "emulator"; then
  echo "❌ No Android emulator detected"
  echo "Please start an Android emulator first:"
  echo "  1. Open Android Studio"
  echo "  2. Go to Tools > AVD Manager"
  echo "  3. Launch an emulator"
  exit 1
fi

echo "✅ Android emulator detected:"
adb devices

cd examples/ai_chat

# Build and install app FIRST to create app directories
echo "🔨 Building app..."
flutter build apk --debug
echo "📲 Installing app..."
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Copy model to a persistent location accessible by the app
echo "📱 Copying model to emulator..."
# Use /data/local/tmp/ which persists and is accessible
adb shell mkdir -p /data/local/tmp/
adb push "$MODEL_PATH" /data/local/tmp/
# Make it world-readable
adb shell chmod 644 /data/local/tmp/$MODEL_FILE

echo "🧪 Running integration tests..."
echo "   Model path in emulator: /data/local/tmp/$MODEL_FILE"
echo
flutter test integration_test/ \
  --device-id emulator-5554 \
  --timeout 5m \
  --dart-define=TEST_MODEL_PATH="/data/local/tmp/$MODEL_FILE" \
  --dart-define=CI=true

echo
echo "✅ Tests completed!"