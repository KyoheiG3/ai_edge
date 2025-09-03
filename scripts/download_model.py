#!/usr/bin/env python3
"""
Download Gemma model from Hugging Face
"""

import os
import sys
import shutil
from pathlib import Path

try:
    from huggingface_hub import hf_hub_download
except ImportError:
    print("Installing huggingface_hub...")
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "huggingface_hub"])
    from huggingface_hub import hf_hub_download

def download_model(repo_id, filename, output_path, token):
    """Download model from Hugging Face and copy to output location"""
    try:
        # Download to cache first
        cache_dir = Path(output_path).parent / ".cache"
        file_path = hf_hub_download(
            repo_id=repo_id,
            filename=filename,
            cache_dir=str(cache_dir),
            force_download=False,
            resume_download=True,
            token=token
        )
        
        # Copy from cache to final location
        shutil.copy2(file_path, output_path)
        print(f"Downloaded to: {output_path}")
        return True
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return False

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: download_model.py <repo_id> <filename> <output_path> <token>")
        sys.exit(1)
    
    repo_id = sys.argv[1]
    filename = sys.argv[2]
    output_path = sys.argv[3]
    token = sys.argv[4]
    
    success = download_model(repo_id, filename, output_path, token)
    sys.exit(0 if success else 1)