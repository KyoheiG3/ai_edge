#!/bin/bash

# iOS integration test runner for macOS
# This script runs the integration tests on iOS simulator

set -e

echo "=== AI Edge iOS Integration Test Runner ==="
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

echo "🍎 Running iOS tests..."
cd examples/ai_chat

# Run iOS tests (flutter will automatically select an iOS simulator)
flutter test integration_test/ \
  --timeout 5m \
  --dart-define=TEST_MODEL_PATH="$MODEL_PATH" \
  --dart-define=CI=true

echo
echo "✅ Tests completed!"