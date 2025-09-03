# AI Edge Flutter Plugin

Flutter plugin for on-device AI inference using MediaPipe GenAI.

## Features

- On-device LLM inference with MediaPipe GenAI
- Support for Gemma models
- Streaming response generation
- Cross-platform support (iOS/Android)

## Setup for Development

### Prerequisites

- Flutter 3.35.2 or higher
- For iOS: Xcode 14.0 or higher
- For Android: Android Studio with NDK

### Running Integration Tests

Integration tests require a Gemma model file. The tests use the `gemma-3n-E2B-it-litert-preview` model.

#### Local Testing

Quick start for iOS (macOS only):
```bash
export HF_TOKEN=your_hugging_face_token
./scripts/test_local_ios.sh
```

Quick start for Android:
```bash
export HF_TOKEN=your_hugging_face_token
./scripts/test_local_android.sh
```

**Note:** The test scripts will automatically download the required model (~3.14GB) on first run and cache it locally. Android tests require at least 8GB of RAM allocated to the emulator.

Or manually:

1. Set up Hugging Face access token:
   ```bash
   export HF_TOKEN=your_hugging_face_token
   ```
   
2. Download the test model:
   ```bash
   ./scripts/download_test_model.sh
   ```

3. Run integration tests:
   ```bash
   cd example
   export TEST_MODEL_PATH=$(realpath ~/models/gemma-3n-E2B-it-int4.task)
   flutter test integration_test \
     --dart-define=TEST_MODEL_PATH="$TEST_MODEL_PATH" \
     --dart-define=HF_TOKEN="$HF_TOKEN" \
     --dart-define=CI=true
   ```

#### CI/CD Setup

For GitHub Actions, add your Hugging Face token as a repository secret:

1. Go to Settings → Secrets and variables → Actions
2. Add a new repository secret named `HF_TOKEN`
3. Set the value to your Hugging Face access token

The token must have access to the Gemma model repository. You can:
1. Get a token from [Hugging Face Settings](https://huggingface.co/settings/tokens)
2. Accept the Gemma model license at [google/gemma-3n-E2B-it-litert-preview](https://huggingface.co/google/gemma-3n-E2B-it-litert-preview)

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

