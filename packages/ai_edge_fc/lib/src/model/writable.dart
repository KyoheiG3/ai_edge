import 'dart:typed_data';

import 'package:protobuf/protobuf.dart';

/// A mixin that provides serialization capabilities for model classes.
///
/// The [Writable] mixin enables model classes to be converted to protobuf
/// format and serialized to binary buffers. This is essential for communication
/// with AI models and services that expect protobuf-formatted data.
///
/// Classes that implement this mixin must provide a [build] method that returns
/// a [GeneratedMessage] (protobuf object), and they automatically get the
/// [writeToBuffer] method for serialization.
///
/// Example usage:
/// ```dart
/// class MyModel with Writable {
///   @override
///   pb.MyProtoMessage build() {
///     return pb.MyProtoMessage(/* ... */);
///   }
/// }
///
/// final model = MyModel();
/// final buffer = model.writeToBuffer(); // Serializes to binary
/// ```
mixin Writable {
  /// Builds and returns the protobuf representation of this object.
  ///
  /// This method must be implemented by classes that use this mixin.
  /// It should create and return the appropriate protobuf message object
  /// that represents the current state of the object.
  ///
  /// Returns a [GeneratedMessage] (protobuf object) representing this object.
  GeneratedMessage build();

  /// Serializes this object to a binary buffer.
  ///
  /// This method converts the object to its protobuf representation using
  /// the [build] method, then serializes it to a binary format that can
  /// be transmitted over networks or stored persistently.
  ///
  /// Returns a [Uint8List] containing the serialized binary data.
  Uint8List writeToBuffer() {
    return build().writeToBuffer();
  }
}
