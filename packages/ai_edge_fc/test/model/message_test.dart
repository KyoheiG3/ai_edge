import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/message.dart';
import 'package:ai_edge_fc/src/model/system_instruction.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

void main() {
  group('Message', () {
    group('when created with role and text', () {
      test('then properties are set correctly', () {
        // Given
        const message = Message(role: 'user', text: 'Hello, world!');

        // Then
        expect(message.role, equals('user'));
        expect(message.text, equals('Hello, world!'));
      });
    });

    group('when build is called', () {
      test('then returns correct protobuf Content', () {
        // Given
        const message = Message(role: 'assistant', text: 'Hi there!');

        // When
        final proto = message.build();

        // Then
        expect(proto.role, equals('assistant'));
        expect(proto.parts.length, equals(1));
        expect(proto.parts.first.hasText(), isTrue);
        expect(proto.parts.first.text, equals('Hi there!'));
      });
    });

    group('when writeToBuffer is called', () {
      test('then returns valid binary data', () {
        // Given
        const message = Message(role: 'user', text: 'Test message');

        // When
        final buffer = message.writeToBuffer();

        // Then
        expect(buffer, isA<List<int>>());
        expect(buffer.isNotEmpty, isTrue);

        // Verify it can be deserialized
        final decoded = pb.Content.fromBuffer(buffer);
        expect(decoded.role, equals('user'));
      });
    });
  });

  group('SystemInstruction', () {
    group('when created with instruction', () {
      test('then instruction is set correctly', () {
        // Given
        const instruction = SystemInstruction(
          instruction: 'Be helpful and concise',
        );

        // Then
        expect(instruction.instruction, equals('Be helpful and concise'));
      });
    });

    group('when build is called', () {
      test('then returns correct protobuf Content', () {
        // Given
        const instruction = SystemInstruction(
          instruction: 'You are a coding assistant',
        );

        // When
        final proto = instruction.build();

        // Then
        expect(proto.role, equals('system'));
        expect(proto.parts.length, equals(1));
        expect(proto.parts.first.text, equals('You are a coding assistant'));
      });
    });
  });
}