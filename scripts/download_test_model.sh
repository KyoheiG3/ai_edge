#!/bin/bash

# Download test model for integration tests
# Usage: ./download_test_model.sh [output_directory]

set -e

# Load model configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/.github/workflows/model.env"
MODEL_REPO="google/gemma-3n-E2B-it-litert-preview"

# Output directory (default to project .models directory)
OUTPUT_DIR="${1:-$PROJECT_ROOT/.models}"
OUTPUT_FILE="$OUTPUT_DIR/$MODEL_FILE"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if model already exists and is valid size (>1GB)
if [ -f "$OUTPUT_FILE" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        FILE_SIZE_BYTES=$(stat -f%z "$OUTPUT_FILE")
    else
        FILE_SIZE_BYTES=$(stat -c%s "$OUTPUT_FILE")
    fi
    
    if [ "$FILE_SIZE_BYTES" -gt 1073741824 ]; then
        echo "[INFO] Using existing model at: $OUTPUT_FILE"
        exit 0
    else
        rm -f "$OUTPUT_FILE"
    fi
fi

# Check if HF_TOKEN is set
if [ -z "$HF_TOKEN" ]; then
    echo "[ERROR] HF_TOKEN environment variable is not set"
    echo "Get a token from: https://huggingface.co/settings/tokens"
    exit 1
fi

# Download using Python script
echo "[INFO] Downloading model..."
if python3 "$SCRIPT_DIR/download_model.py" "$MODEL_REPO" "$MODEL_FILE" "$OUTPUT_FILE" "$HF_TOKEN"; then
    echo "[INFO] Model ready at: $OUTPUT_FILE"
else
    echo "[ERROR] Failed to download model"
    exit 1
fi