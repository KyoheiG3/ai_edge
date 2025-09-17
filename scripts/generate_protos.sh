#!/bin/bash

# Script to download and generate proto files by fetching only required files directly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GITHUB_RAW="https://raw.githubusercontent.com"
AI_EDGE_REPO="google-ai-edge/ai-edge-apis/main"
PROTOBUF_REPO="protocolbuffers/protobuf/v32.1"
TEMP_DIR="$(mktemp -d)"
OUTPUT_DIR="packages/ai_edge_fc/lib/src/proto"
PROTOC_CMD="protoc"

# Proto files to download (path relative to repo root)
PROTO_FILES=(
    "local_agents/core/proto/content.proto"
    "local_agents/core/proto/generative_service.proto"
    "local_agents/function_calling/core/proto/constraint_options.proto"
    "local_agents/function_calling/core/proto/model_formatter_options.proto"
)

# Get the root directory (parent of scripts directory)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# ============================================================================
# Helper Functions
# ============================================================================

# Print colored message
log() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

log_info() { log "$GREEN" "$@"; }
log_warn() { log "$YELLOW" "$@"; }
log_error() { log "$RED" "$@"; }

# Download a file from GitHub
download_file() {
    local repo=$1
    local path=$2
    local dest=$3
    
    local url="$GITHUB_RAW/$repo/$path"
    local dir=$(dirname "$dest")
    
    # Create directory if needed
    mkdir -p "$dir"
    
    # Download file
    log_warn "  Downloading: $path"
    if ! curl -sL -o "$dest" "$url"; then
        log_error "Failed to download $path"
        return 1
    fi
    return 0
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Register cleanup function to run on exit
trap cleanup EXIT

# ============================================================================
# Main Script
# ============================================================================

log_info "Starting proto generation process (Direct download method)..."
log_warn "Using temporary directory: $TEMP_DIR"

# Check if required tools are installed
for tool in curl $PROTOC_CMD; do
    if ! command -v $tool &> /dev/null; then
        log_error "Error: $tool is not installed or not in PATH"
        exit 1
    fi
done

log_warn "Using protoc at: $(which $PROTOC_CMD)"

# Clean and create output directory
log_info "Cleaning output directory..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Download AI Edge API proto files
log_info "Downloading AI Edge API proto files..."
for proto_path in "${PROTO_FILES[@]}"; do
    if ! download_file "$AI_EDGE_REPO" "$proto_path" "$TEMP_DIR/$proto_path"; then
        exit 1
    fi
done

# Download Google protobuf struct.proto
log_info "Downloading Google protobuf struct.proto..."
if ! download_file "$PROTOBUF_REPO" "src/google/protobuf/struct.proto" "$TEMP_DIR/google/protobuf/struct.proto"; then
    exit 1
fi

# Generate proto files
log_info "Generating Dart files from proto files..."

# Change to temp directory for proper imports
cd "$TEMP_DIR"

# Collect all proto files to compile
all_proto_files=""

# Add AI Edge proto files
for proto_path in "${PROTO_FILES[@]}"; do
    if [ -f "$proto_path" ]; then
        all_proto_files="$all_proto_files $proto_path"
        log_warn "  Processing: $proto_path"
    fi
done

# Add Google protobuf struct.proto
if [ -f "google/protobuf/struct.proto" ]; then
    all_proto_files="$all_proto_files google/protobuf/struct.proto"
    log_warn "  Processing: google/protobuf/struct.proto"
fi

# Generate all proto files at once
if [ -n "$all_proto_files" ]; then
    if ! $PROTOC_CMD \
        --dart_out="grpc:$ROOT_DIR/$OUTPUT_DIR" \
        --proto_path="." \
        $all_proto_files; then
        log_error "Error generating proto files"
        cd "$ROOT_DIR"
        exit 1
    fi
else
    log_error "No proto files found to generate"
    cd "$ROOT_DIR"
    exit 1
fi

cd "$ROOT_DIR"

# Move Google protobuf files to correct location if needed
if [ -d "$OUTPUT_DIR/protobuf/src/google" ]; then
    log_info "Moving Google protobuf files to correct location..."
    mv "$OUTPUT_DIR/protobuf/src/google" "$OUTPUT_DIR/" 2>/dev/null || true
    rm -rf "$OUTPUT_DIR/protobuf"
fi

# Count and display generated files
GENERATED_COUNT=$(find "$OUTPUT_DIR" -name "*.dart" -type f | wc -l)

log_info "✅ Proto generation complete!"
log_info "Generated $GENERATED_COUNT Dart files in $OUTPUT_DIR"

# List generated files
log_warn "Generated files:"
find "$OUTPUT_DIR" -name "*.dart" -type f | sort | while read -r file; do
    echo "  - ${file#$OUTPUT_DIR/}"
done