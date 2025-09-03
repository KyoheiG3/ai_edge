#!/bin/bash

# Android integration test runner for macOS
# This script runs the integration tests on Android emulator

set -e

echo "=== AI Edge Android Integration Test Runner ==="
echo

# Check if HF_TOKEN is set
if [ -z "$HF_TOKEN" ]; then
  echo "❌ HF_TOKEN environment variable is not set"
  echo "Please set it with: export HF_TOKEN=your_token_here"
  echo "Get a token from: https://huggingface.co/settings/tokens"
  exit 1
fi

# Download model if needed
echo "📥 Checking for test model..."
./scripts/download_test_model.sh ~/models

# Get model path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.github/workflows/model.env"
MODEL_PATH=$(realpath ~/models/$MODEL_FILE)

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

cd example

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
flutter test integration_test \
  --device-id emulator-5554 \
  --timeout 5m \
  --fail-fast \
  --dart-define=TEST_MODEL_PATH="/data/local/tmp/$MODEL_FILE" \
  --dart-define=HF_TOKEN="$HF_TOKEN" \
  --dart-define=CI=true

echo
echo "✅ Tests completed!"