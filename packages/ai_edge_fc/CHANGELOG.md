## 0.0.1

Initial release of the AI Edge Function Calling plugin for on-device AI with function calling capabilities.

### Features

* **Function Calling Support**: Comprehensive function calling implementation for Google MediaPipe GenAI
  - Tool and function declaration support
  - Function execution with structured responses
  - Support for multiple function calls in a single request
  
* **Model Formatters**: Support for multiple model formatting strategies
  - GemmaFormatter for Gemma models
  - HammerFormatter for Hammer models
  - LlamaFormatter for Llama models
  
* **Structured Data**: Protocol Buffer-based data structures
  - Type-safe message passing between Dart and native code
  - Support for complex nested data structures
  - Automatic serialization/deserialization
  
* **Streaming Support**: Real-time streaming responses for function calls
  - Incremental response processing
  - Function call detection during streaming
  
* **Example Functions**: Built-in example function implementations
  - Weather information retrieval
  - Calculator operations
  - Current time function

### Platform Support

* Android support with MediaPipe GenAI integration
* iOS support pending (platform limitations)

### Developer Experience

* Complete example application demonstrating all features
* Comprehensive test coverage for all models
* Clean API design with intuitive usage patterns
