#!/bin/bash

# Download test model for CI/CD integration tests
# Usage: ./download_test_model.sh [output_directory]

set -e

# Configuration
MODEL_URL="https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task"
MODEL_FILE="gemma-3n-E2B-it-int4.task"
MODEL_SIZE_GB="3.14"

# Expected SHA256 from Hugging Face
EXPECTED_SHA256="a7f544cfee68f579fabadb22aa9284faa4020a0f5358d0e15b49fdd4cefe4200"

# Output directory (default to ~/models)
OUTPUT_DIR="${1:-$HOME/models}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_disk_space() {
    local required_gb=4  # Model size + buffer
    local available_gb
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        available_gb=$(df -g "$OUTPUT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
    else
        # Linux
        available_gb=$(df -BG "$OUTPUT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "0")
    fi
    
    if [ "$available_gb" -lt "$required_gb" ]; then
        log_error "Insufficient disk space. Required: ${required_gb}GB, Available: ${available_gb}GB"
        exit 1
    fi
    
    log_info "Disk space check passed. Available: ${available_gb}GB"
}

download_with_resume() {
    local url="$1"
    local output_file="$2"
    local auth_header=""
    
    # Add authorization header if HF_TOKEN is set
    if [ -n "$HF_TOKEN" ]; then
        auth_header="Authorization: Bearer $HF_TOKEN"
        log_info "Using Hugging Face authentication token"
    fi
    
    log_info "Downloading from: $url"
    log_info "Saving to: $output_file"
    
    # Use curl with resume capability
    if [ -n "$auth_header" ]; then
        curl -L -C - -H "$auth_header" \
             --progress-bar \
             --retry 3 \
             --retry-delay 5 \
             -o "$output_file" \
             "$url"
    else
        curl -L -C - \
             --progress-bar \
             --retry 3 \
             --retry-delay 5 \
             -o "$output_file" \
             "$url"
    fi
    
    return $?
}

verify_checksum() {
    local file="$1"
    local expected="$2"
    
    if [ -z "$expected" ]; then
        log_warn "No checksum provided, skipping verification"
        return 0
    fi
    
    log_info "Verifying file checksum..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        actual=$(shasum -a 256 "$file" | awk '{print $1}')
    else
        # Linux
        actual=$(sha256sum "$file" | awk '{print $1}')
    fi
    
    if [ "$actual" != "$expected" ]; then
        log_error "Checksum verification failed!"
        log_error "Expected: $expected"
        log_error "Actual:   $actual"
        return 1
    fi
    
    log_info "Checksum verification passed"
    return 0
}

# Main script
main() {
    log_info "Starting model download for integration tests"
    log_info "Model: $MODEL_FILE ($MODEL_SIZE_GB GB)"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Full path to output file
    OUTPUT_FILE="$OUTPUT_DIR/$MODEL_FILE"
    
    # Check if model already exists
    if [ -f "$OUTPUT_FILE" ]; then
        log_info "Model file already exists at: $OUTPUT_FILE"
        
        # Verify existing file if checksum is provided
        if [ -n "$EXPECTED_SHA256" ]; then
            if verify_checksum "$OUTPUT_FILE" "$EXPECTED_SHA256"; then
                log_info "Existing model verified successfully"
                exit 0
            else
                log_warn "Existing model failed verification, re-downloading..."
                rm -f "$OUTPUT_FILE"
            fi
        else
            # Ask if we should re-download
            if [ -t 0 ]; then  # Check if running interactively
                read -p "Model exists. Re-download? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Using existing model"
                    exit 0
                fi
                rm -f "$OUTPUT_FILE"
            else
                # Non-interactive mode (CI), use existing file
                log_info "Using existing model (non-interactive mode)"
                exit 0
            fi
        fi
    fi
    
    # Check disk space
    check_disk_space
    
    # Download the model
    log_info "Starting download..."
    if download_with_resume "$MODEL_URL" "$OUTPUT_FILE"; then
        log_info "Download completed successfully"
    else
        log_error "Download failed"
        rm -f "$OUTPUT_FILE"
        exit 1
    fi
    
    # Verify the downloaded file
    if [ -n "$EXPECTED_SHA256" ]; then
        if ! verify_checksum "$OUTPUT_FILE" "$EXPECTED_SHA256"; then
            rm -f "$OUTPUT_FILE"
            exit 1
        fi
    fi
    
    # Show file info
    if [[ "$OSTYPE" == "darwin"* ]]; then
        FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    else
        FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    fi
    
    log_info "Model downloaded successfully!"
    log_info "Location: $OUTPUT_FILE"
    log_info "Size: $FILE_SIZE"
    
    # For CI environments, output the path for other scripts
    if [ -n "$CI" ]; then
        echo "::set-output name=model_path::$OUTPUT_FILE"
    fi
}

# Run main function
main "$@"