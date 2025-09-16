## 0.2.0

### Breaking Changes

* **API Simplification**: Replaced config objects with individual named parameters (#11)
  - `createModel()` now accepts individual parameters instead of `ModelConfig` object
  - `createSession()` now accepts individual parameters instead of `SessionConfig` object  
  - `initialize()` now accepts individual parameters for both model and session configuration
  - Config classes (`ModelConfig` and `SessionConfig`) are still available internally but not exposed in public API

### Improvements

* **Developer Experience**:
  - More intuitive API with direct parameter passing
  - Better IDE autocomplete support without config object nesting
  - Optional parameters with sensible defaults:
    - `maxTokens`: Default 1024 (previously required)
    - `temperature`: Default 0.8
    - `randomSeed`: Default 1
    - `topK`: Default 40

* **Platform Implementation**:
  - Made non-critical parameters optional in Android native implementation
  - Fixed platform channel communication issues with Unit type handling

* **Code Quality**:
  - Removed unnecessary `toString()` override from `GenerationEvent` class
  - Updated documentation to remove references to deprecated exception types
  - Updated tests to reflect the new API design

## 0.1.0

### Breaking Changes

* **Package Structure**: Reorganized package to use `src/` directory structure
  - Main implementation moved to `lib/src/` directory
  - Public API now exported through `lib/ai_edge.dart`
  - Platform interfaces moved to `src/` subdirectory

* **Error Handling**: Complete overhaul of error handling system
  - Introduced sealed classes (`AiEdgeException`) for exhaustive error handling
  - Replaced string-based errors with type-safe exception hierarchy
  - `CallError` now accepts `Exception` directly instead of message strings
  - Removed unnecessary `PlatformException` conversions

* **Platform Interface**: Standardized data conversion patterns
  - Platform interfaces now accept `Map<String, dynamic>` instead of typed objects
  - Data conversion happens in upper layer (ai_edge.dart) for consistency
  - Cleaner separation between platform communication and business logic

### Features

* **Monorepo Structure**: Project reorganized as Flutter workspace
  - Packages moved to `packages/` directory
  - Examples moved to `examples/` directory
  - Enables better package management and development workflow

### Improvements

* **Code Quality**
  - Improved test coverage with updated mock implementations
  - Better separation of concerns with `src/` directory structure
  - More maintainable and extensible codebase

* **Developer Experience**
  - Cleaner public API surface
  - Better IDE support with organized file structure
  - Improved error messages with sealed class pattern

### Chores

* Added LICENSE and README.md symlinks for pub.dev publishing requirements
* Updated dependencies and build configurations
* Improved Android build configuration

## 0.0.1

Initial release of the AI Edge Flutter plugin for on-device AI inference using MediaPipe GenAI.

### Features

* **Native AI Inference**: On-device AI inference support for both iOS and Android platforms using MediaPipe GenAI
* **Streaming Responses**: Real-time streaming text generation with async stream support
* **Model Management**: Built-in model download and management capabilities
* **Example App**: Comprehensive example application with chat UI and model management interface
* **Platform Support**:
  - iOS 13.0+ with MediaPipeTasksGenAI (0.10.24)
  - Android with MediaPipe GenAI (0.10.24)

### Infrastructure

* Comprehensive CI/CD workflow with platform-specific builds
* Integration and unit test infrastructure
* Automated code formatting and linting
* Pull request template for consistent contributions

### Developer Experience

* Project documentation for pub.dev release
* Tool version management with mise configuration
* Simplified plugin architecture with clean API design
* Example app demonstrating all plugin capabilities
