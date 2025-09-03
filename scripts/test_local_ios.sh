#!/bin/bash

# iOS integration test runner for macOS
# This script runs the integration tests on iOS simulator

set -e

echo "=== AI Edge iOS Integration Test Runner ==="
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

echo "🍎 Running iOS tests..."
cd example

# Run iOS tests (flutter will automatically select an iOS simulator)
flutter test integration_test \
  --timeout 5m \
  --fail-fast \
  --dart-define=TEST_MODEL_PATH="$MODEL_PATH" \
  --dart-define=HF_TOKEN="$HF_TOKEN" \
  --dart-define=CI=true

echo
echo "✅ Tests completed!"