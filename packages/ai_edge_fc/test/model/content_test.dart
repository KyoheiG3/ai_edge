import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/content.dart';
import 'package:ai_edge_fc/src/model/part.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

void main() {
  group('Content', () {
    group('when created', () {
      test('then properties are set', () {
        // Given
        final content = Content(
          role: 'user',
          parts: [
            Part(text: 'Hello'),
            Part(text: 'World'),
          ],
        );

        // Then
        expect(content.role, equals('user'));
        expect(content.parts.length, equals(2));
        expect(content.parts.first.text, equals('Hello'));
      });
    });

    group('when fromProto is called', () {
      test('then creates instance from protobuf', () {
        // Given
        final proto = pb.Content()
          ..role = 'assistant'
          ..parts.addAll([pb.Part()..text = 'Response text']);

        // When
        final content = Content.fromProto(proto);

        // Then
        expect(content.role, equals('assistant'));
        expect(content.parts.length, equals(1));
        expect(content.parts.first.text, equals('Response text'));
      });
    });

    group('when build is called', () {
      test('then generates correct protobuf', () {
        // Given
        final content = Content(
          role: 'model',
          parts: [
            Part(text: 'First part'),
            Part(text: 'Second part'),
          ],
        );

        // When
        final proto = content.build();

        // Then
        expect(proto.role, equals('model'));
        expect(proto.parts.length, equals(2));
        expect(proto.parts[0].text, equals('First part'));
        expect(proto.parts[1].text, equals('Second part'));
      });
    });
  });
}