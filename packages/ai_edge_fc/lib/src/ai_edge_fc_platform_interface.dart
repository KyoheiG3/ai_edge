import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ai_edge_fc_method_channel.dart';

/// The base platform interface for AiEdgeFc plugin.
abstract class AiEdgeFcPlatform extends PlatformInterface {
  /// Constructs an AiEdgeFcPlatform.
  AiEdgeFcPlatform() : super(token: _token);

  static final Object _token = Object();

  static AiEdgeFcPlatform _instance = MethodChannelAiEdgeFc();

  /// The default instance of [AiEdgeFcPlatform] to use.
  ///
  /// Defaults to [MethodChannelAiEdgeFc].
  static AiEdgeFcPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AiEdgeFcPlatform] when
  /// they register themselves.
  static set instance(AiEdgeFcPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Creates a new model with the given configuration.
  Future<void> createModel(Map<String, dynamic> options) {
    throw UnimplementedError('createModel() has not been implemented.');
  }

  /// Creates a new session with the given configuration.
  Future<void> createSession(Map<String, dynamic> arguments) {
    throw UnimplementedError('createSession() has not been implemented.');
  }

  /// Creates a copy of the current session.
  Future<void> cloneSession() {
    throw UnimplementedError('cloneSession() has not been implemented.');
  }

  /// Enables output constraints for controlled generation.
  Future<void> enableConstraint(Map<String, dynamic> arguments) {
    throw UnimplementedError('enableConstraint() has not been implemented.');
  }

  /// Disables any active output constraints.
  Future<void> disableConstraint() {
    throw UnimplementedError('disableConstraint() has not been implemented.');
  }

  /// Sets the available tools for function calling.
  Future<void> setTools(Map<String, dynamic> arguments) {
    throw UnimplementedError('setTools() has not been implemented.');
  }

  /// Sets the system instruction for the model.
  Future<void> setSystemInstruction(Map<String, dynamic> arguments) {
    throw UnimplementedError(
      'setSystemInstruction() has not been implemented.',
    );
  }

  /// Sends a message to the model and returns the response.
  Future<Uint8List> sendMessage(Map<String, dynamic> arguments) {
    throw UnimplementedError('sendMessage() has not been implemented.');
  }

  /// Retrieves the conversation history.
  Future<Iterable<Uint8List>> getHistory() {
    throw UnimplementedError('getHistory() has not been implemented.');
  }

  /// Gets the last message in the conversation.
  Future<Uint8List?> getLast() {
    throw UnimplementedError('getLast() has not been implemented.');
  }

  /// Releases all resources associated with the model and session.
  Future<void> close() {
    throw UnimplementedError('close() has not been implemented.');
  }
}
