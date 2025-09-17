# AI Edge FC (Function Calling)

[![pub package](https://img.shields.io/pub/v/ai_edge_fc.svg)](https://pub.dev/packages/ai_edge_fc)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://pub.dev/packages/ai_edge_fc)
[![License: BSD](https://img.shields.io/badge/license-BSD-purple.svg)](https://opensource.org/licenses/BSD-3-Clause)

A Flutter plugin for on-device AI inference with function calling capabilities powered by MediaPipe GenAI. Enable your LLMs to interact with external tools and APIs while keeping everything on-device.

## Features

- 🛠️ **Function Calling** - Let LLMs call predefined functions with structured arguments
- 🔄 **Tool Integration** - Define multiple tools that the model can use
- 📊 **Structured Output** - Control model output format with constraints
- 🚀 **On-device inference** - All processing happens locally, no internet required
- 🔒 **Privacy-first** - Your data never leaves the device
- 💬 **Conversation Management** - Maintain context across function calls
- 🎯 **System Instructions** - Guide model behavior with system prompts

## Installation

```bash
flutter pub add ai_edge_fc
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  ai_edge_fc:
```

## Getting Started

### 1. Basic Setup

```dart
import 'package:ai_edge_fc/ai_edge_fc.dart';

// Get the AI Edge FC instance
final aiEdgeFc = AiEdgeFc.instance;

// Step 1: Create the model
await aiEdgeFc.createModel(
  modelPath: '/path/to/your/model.task',
  maxTokens: 512,
);

// Step 2: Set system instruction (BEFORE createSession!)
await aiEdgeFc.setSystemInstruction(
  SystemInstruction(
    instruction: 'You are a helpful assistant. Use functions when appropriate.',
  ),
);

// Step 3: Define functions the model can call (BEFORE createSession!)
final functions = [
  FunctionDeclaration(
    name: 'get_weather',
    description: 'Get the current weather for a location',
    properties: [
      FunctionProperty(
        name: 'location',
        description: 'The city name',
        type: PropertyType.string,
        required: true,
      ),
    ],
  ),
];
await aiEdgeFc.setFunctions(functions);

// Step 4: Create the session (AFTER setting functions and system instruction)
await aiEdgeFc.createSession(
  temperature: 0.7,
);

// Send a message that might trigger a function call
final response = await aiEdgeFc.sendMessage(
  Message(role: 'user', text: 'What\'s the weather in Tokyo?')
);

// Check if the model wants to call a function
if (response.functionCall != null) {
  print('Function to call: ${response.functionCall!.name}');
  print('Arguments: ${response.functionCall!.args.fields}');
  
  // Execute the function and send the result back
  final weatherData = await getWeatherData('Tokyo'); // Your implementation
  final functionResponse = FunctionResponse(
    functionCall: response.functionCall!,
    response: weatherData,
  );
  
  final finalResponse = await aiEdgeFc.sendFunctionResponse(functionResponse);
  print('Final response: ${finalResponse.text}');
}

// Clean up when done
await aiEdgeFc.close();
```

### 2. Model Requirements

This plugin requires a MediaPipe Task format model (`.task` file) with function calling support. The model must be specifically trained or fine-tuned to understand and generate function calls.

Place the model file in your app's documents directory or assets.

## Usage

### Important: Initialization Order

⚠️ **IMPORTANT**: You must call `setSystemInstruction` and `setFunctions` **BEFORE** calling `createSession`. The session needs to be created with knowledge of the available functions and system instructions.

```dart
// ✅ Correct order (functions must be set before session):
await aiEdgeFc.setSystemInstruction(SystemInstruction(...));  // Can be before or after createModel
await aiEdgeFc.setFunctions([...]);                           // Can be before or after createModel
await aiEdgeFc.createModel(modelPath: modelPath);
await aiEdgeFc.createSession();                               // Must be AFTER setting functions

// ❌ Incorrect order (functions won't work):
await aiEdgeFc.createModel(modelPath: modelPath);
await aiEdgeFc.createSession();
await aiEdgeFc.setFunctions([...]);  // Too late! Session already created
```

### Define Functions

```dart
// Define a calculator function
final calculator = FunctionDeclaration(
  name: 'calculate',
  description: 'Perform mathematical calculations',
  properties: [
    FunctionProperty(
      name: 'expression',
      type: PropertyType.string,
      description: 'Mathematical expression to evaluate',
      required: true,
    ),
  ],
);

// Define a database query function
final databaseQuery = FunctionDeclaration(
  name: 'query_database',
  description: 'Query product information from database',
  properties: [
    FunctionProperty(
      name: 'product_name',
      type: PropertyType.string,
      description: 'Name of the product to search',
      required: true,
    ),
    FunctionProperty(
      name: 'limit',
      type: PropertyType.integer,
      description: 'Maximum number of results',
      required: false,
    ),
  ],
);

// Set multiple functions
await aiEdgeFc.setFunctions([calculator, databaseQuery]);
```

### Handle Function Calls

```dart
// Send user message
final response = await aiEdgeFc.sendMessage(
  Message(role: 'user', text: 'How much is 15% of 200?')
);

// Handle function call
if (response.functionCall != null) {
  final call = response.functionCall!;
  
  switch (call.name) {
    case 'calculate':
      final expression = call.args.fields['expression'] as String;
      final result = evaluateExpression(expression); // Your implementation
      
      final functionResponse = FunctionResponse(
        functionCall: call,
        response: {'result': result},
      );
      
      final finalResponse = await aiEdgeFc.sendFunctionResponse(functionResponse);
      print(finalResponse.text); // "15% of 200 is 30"
      break;
      
    case 'query_database':
      // Handle database query
      break;
  }
}
```

### Use Tools (Multiple Functions)

```dart
// Group related functions into tools
final tools = [
  Tool(
    functionDeclarations: [
      FunctionDeclaration(name: 'get_weather', ...),
      FunctionDeclaration(name: 'get_forecast', ...),
    ],
  ),
  Tool(
    functionDeclarations: [
      FunctionDeclaration(name: 'search_web', ...),
      FunctionDeclaration(name: 'get_news', ...),
    ],
  ),
];

await aiEdgeFc.setTools(tools);
```

### Control Output with Constraints

```dart
// Force the model to only call functions (no text responses)
final constraints = ConstraintOptions(
  toolCallOnly: ToolCallOnly(
    constraintPrefix: 'Function: ',
    constraintSuffix: '\n',
  ),
);

await aiEdgeFc.enableConstraint(constraints);

// Disable constraints when needed
await aiEdgeFc.disableConstraint();
```

### Set System Instructions

```dart
// Guide the model's behavior
final systemInstruction = SystemInstruction(
  instruction: '''You are a helpful assistant with access to various tools.
Always use the appropriate function when the user asks for specific information.
Be concise and accurate in your responses.'''
);

await aiEdgeFc.setSystemInstruction(systemInstruction);
```

### Manage Conversation History

```dart
// Get conversation history
final history = await aiEdgeFc.getHistory();
for (final content in history) {
  print('${content.role}: ${content.parts.first.text}');
}

// Get the last message
final lastMessage = await aiEdgeFc.getLast();
if (lastMessage != null) {
  print('Last message: ${lastMessage.parts.first.text}');
}

// Clone session to preserve state
await aiEdgeFc.cloneSession();
```

## API Reference

### Main Classes

#### `AiEdgeFc`
The main entry point for function calling capabilities.

#### `FunctionDeclaration`
Defines a function that the model can call:
- `name`: Function identifier
- `description`: What the function does
- `properties`: List of function parameters

#### `FunctionProperty`
Defines a function parameter:
- `name`: Parameter name
- `type`: Data type (PropertyType.string, PropertyType.number, PropertyType.integer, PropertyType.boolean, PropertyType.object, PropertyType.array)
- `description`: Parameter description
- `required`: Whether the parameter is required

#### `Message`
User or assistant message:
- `role`: Message sender ('user', 'assistant', 'function')
- `text`: Message content

#### `FunctionCall`
Represents a function call request from the model:
- `name`: Function to call
- `args`: Structured arguments as key-value pairs

#### `FunctionResponse`
Response from a function execution:
- `functionCall`: The original function call
- `response`: Result data as a map
- `role`: Optional role identifier

#### `ConstraintOptions`
Output format constraints:
- `toolCallOnly`: Force function-only responses
- `textAndOr`: Text with stop conditions
- `textUntil`: Generate until stop phrase

#### `GenerateContentResponse`
Model's response containing:
- `text`: Generated text (if any)
- `functionCall`: Function call request (if any)

## Platform Support

### iOS

❌ **Not yet supported** - Function calling features are currently Android-only. iOS support is planned for a future release.

### Android

- **Minimum SDK**: Android API level 24 (Android 7.0) or later
  - This is a requirement from MediaPipe GenAI SDK
  - Flutter's default minSdkVersion is 21, so you **must** update it

- Add to your `android/app/build.gradle`:
  ```gradle
  android {
    defaultConfig {
        minSdkVersion 24  // Required by MediaPipe GenAI
    }
  }
  ```

- **Recommended Devices**: 
  - Optimal performance on Pixel 7 or newer
  - Other high-end Android devices with comparable specs

- For large models, you may need to increase heap size in `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <application
    android:largeHeap="true"
    ...>
  ```

## Example App

Check out the [examples/ai_chat_fc](../../examples/ai_chat_fc/) directory for a complete chat application with function calling demonstrations:

- Weather information retrieval (simulated)
- Calculator functions (basic arithmetic)
- Time and date information
- Multi-turn conversations with context
- Error handling and recovery

Run the example:
```bash
cd examples/ai_chat_fc
flutter run
```

## Troubleshooting

### Common Issues

**Function calls not being recognized:**
- Ensure your model supports function calling
- Verify function declarations are properly formatted
- Check that system instructions guide the model appropriately

**Arguments parsing fails:**
- Validate that the model returns properly structured JSON
- Use the `Struct` class for complex argument structures

**Model doesn't call functions when expected:**
- Use `ConstraintOptions` to force function calls
- Provide clear system instructions
- Include examples in your prompts

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## Links

- [Pub.dev Package](https://pub.dev/packages/ai_edge_fc)
- [GitHub Repository](https://github.com/KyoheiG3/ai_edge)
- [Issue Tracker](https://github.com/KyoheiG3/ai_edge/issues)
- [MediaPipe Documentation](https://developers.google.com/mediapipe)