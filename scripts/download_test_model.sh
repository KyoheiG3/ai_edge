#!/bin/bash

# Download test model for CI/CD integration tests
# Usage: ./download_test_model.sh [output_directory]

set -e

# Configuration
MODEL_REPO="google/gemma-3n-E2B-it-litert-preview"
MODEL_FILE="gemma-3n-E2B-it-int4.task"
MODEL_SIZE_GB="3.14"

# SHA256 of the actual model file (not the LFS pointer)
# If empty, verification will be skipped
EXPECTED_SHA256=""

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

# Not used anymore - keeping for reference
# download_with_resume() - replaced with huggingface-hub methods

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
    log_info "Model: $MODEL_FILE ($MODEL_SIZE_GB GB) from $MODEL_REPO"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Full path to output file
    OUTPUT_FILE="$OUTPUT_DIR/$MODEL_FILE"
    
    # Check if model already exists
    if [ -f "$OUTPUT_FILE" ]; then
        log_info "Model file already exists at: $OUTPUT_FILE"
        
        # Check file size
        if [[ "$OSTYPE" == "darwin"* ]]; then
            FILE_SIZE_BYTES=$(stat -f%z "$OUTPUT_FILE")
        else
            FILE_SIZE_BYTES=$(stat -c%s "$OUTPUT_FILE")
        fi
        
        # If file is larger than 1GB, it's probably the real model
        if [ "$FILE_SIZE_BYTES" -gt 1073741824 ]; then
            log_info "Existing model appears to be valid (size: $(( FILE_SIZE_BYTES / 1024 / 1024 / 1024 ))GB)"
            
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
                # No checksum, but size looks good
                log_info "Using existing model (no checksum verification)"
                exit 0
            fi
        else
            log_warn "Existing file is too small ($(( FILE_SIZE_BYTES / 1024 / 1024 ))MB), likely an LFS pointer"
            rm -f "$OUTPUT_FILE"
        fi
    fi
    
    # Check disk space
    check_disk_space
    
    # Try different download methods
    log_info "Attempting to download model using huggingface-hub..."
    
    # Method 1: Try using huggingface-cli if available
    if command -v huggingface-cli &> /dev/null || command -v hf &> /dev/null; then
        # Check if HF_TOKEN is set
        if [ -z "$HF_TOKEN" ]; then
            log_error "HF_TOKEN environment variable is required for accessing Gemma models"
            log_info "Please set HF_TOKEN with a Hugging Face token that has access to the Gemma model"
            log_info "You can get a token from: https://huggingface.co/settings/tokens"
            exit 1
        fi
        
        # Try new hf command first, fallback to huggingface-cli
        if command -v hf &> /dev/null; then
            log_info "Using hf download command"
            hf download "$MODEL_REPO" "$MODEL_FILE" \
                --local-dir "$OUTPUT_DIR" \
                --local-dir-use-symlinks False \
                --token "$HF_TOKEN"
        else
            log_info "Using huggingface-cli to download"
            huggingface-cli download "$MODEL_REPO" "$MODEL_FILE" \
                --local-dir "$OUTPUT_DIR" \
                --local-dir-use-symlinks False \
                --token "$HF_TOKEN"
        fi
        
        if [ -f "$OUTPUT_FILE" ]; then
            log_info "Download with huggingface-cli completed"
        else
            log_error "huggingface-cli download failed"
            exit 1
        fi
    # Method 2: Try Python with huggingface_hub if available  
    elif command -v python3 &> /dev/null; then
        # Check if HF_TOKEN is set
        if [ -z "$HF_TOKEN" ]; then
            log_error "HF_TOKEN environment variable is required for accessing Gemma models"
            log_info "Please set HF_TOKEN with a Hugging Face token that has access to the Gemma model"
            log_info "You can get a token from: https://huggingface.co/settings/tokens"
            exit 1
        fi
        
        log_info "Trying to download using Python huggingface_hub"
        python3 -c "
import os
os.environ['HF_TOKEN'] = '$HF_TOKEN'

try:
    from huggingface_hub import hf_hub_download
    
    file_path = hf_hub_download(
        repo_id='$MODEL_REPO',
        filename='$MODEL_FILE',
        cache_dir='$OUTPUT_DIR/.cache',
        force_download=False,
        resume_download=True,
        token='$HF_TOKEN'
    )
    
    # Move from cache to output location
    import shutil
    shutil.copy2(file_path, '$OUTPUT_FILE')
    print(f'Downloaded to: $OUTPUT_FILE')
except ImportError:
    print('huggingface_hub not installed, trying pip install...')
    import subprocess
    subprocess.run(['pip', 'install', '-q', 'huggingface_hub'])
    
    # Try again
    from huggingface_hub import hf_hub_download
    
    file_path = hf_hub_download(
        repo_id='$MODEL_REPO',
        filename='$MODEL_FILE',
        cache_dir='$OUTPUT_DIR/.cache',
        force_download=False,
        resume_download=True,
        token='$HF_TOKEN'
    )
    
    import shutil
    shutil.copy2(file_path, '$OUTPUT_FILE')
    print(f'Downloaded to: $OUTPUT_FILE')
except Exception as e:
    print(f'Error: {e}')
    exit(1)
"
        if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
            log_info "Download with Python completed"
        else
            log_error "Python download failed, trying git lfs..."
            
            # Method 3: Use git lfs as last resort
            log_info "Cloning repository with git lfs..."
            TEMP_REPO="/tmp/gemma_model_$$"
            git clone --depth 1 --filter=blob:none --sparse \
                "https://huggingface.co/$MODEL_REPO" "$TEMP_REPO"
            
            cd "$TEMP_REPO"
            git sparse-checkout set "$MODEL_FILE"
            git lfs pull --include="$MODEL_FILE"
            
            if [ -f "$MODEL_FILE" ]; then
                mv "$MODEL_FILE" "$OUTPUT_FILE"
                cd - >/dev/null
                rm -rf "$TEMP_REPO"
                log_info "Download with git lfs completed"
            else
                cd - >/dev/null
                rm -rf "$TEMP_REPO"
                log_error "All download methods failed"
                exit 1
            fi
        fi
    else
        log_error "No suitable download method available (need huggingface-cli, Python, or git lfs)"
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
        FILE_SIZE_BYTES=$(stat -f%z "$OUTPUT_FILE")
    else
        FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
        FILE_SIZE_BYTES=$(stat -c%s "$OUTPUT_FILE")
    fi
    
    log_info "Model downloaded successfully!"
    log_info "Location: $OUTPUT_FILE"
    log_info "Size: $FILE_SIZE ($FILE_SIZE_BYTES bytes)"
    
    # Check if file size is suspiciously small (less than 1MB)
    if [ "$FILE_SIZE_BYTES" -lt 1048576 ]; then
        log_warn "File size is suspiciously small! Expected ~3.14GB but got $FILE_SIZE"
        log_warn "This might be a Git LFS pointer file instead of the actual model"
        log_info "First 500 bytes of file content:"
        head -c 500 "$OUTPUT_FILE" | cat -v
    fi
    
    # For CI environments, output the path for other scripts
    if [ -n "$CI" ]; then
        echo "::set-output name=model_path::$OUTPUT_FILE"
    fi
}

# Run main function
main "$@"