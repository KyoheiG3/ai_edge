import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/part.dart';
import 'package:ai_edge_fc/src/model/function_call.dart';
import 'package:ai_edge_fc/src/model/struct.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;
import 'package:ai_edge_fc/src/proto/google/protobuf/struct.pb.dart'
    as structpb;

void main() {
  group('Part', () {
    group('when created with text', () {
      test('then text is set', () {
        // Given
        const part = Part(text: 'Some text');

        // Then
        expect(part.text, equals('Some text'));
        expect(part.functionCall, isNull);
      });
    });

    group('when created with function call', () {
      test('then function call is set', () {
        // Given
        const part = Part(
          functionCall: FunctionCall(
            name: 'test',
            args: Struct(fields: {}),
          ),
        );

        // Then
        expect(part.text, isNull);
        expect(part.functionCall?.name, equals('test'));
      });
    });

    group('when fromProto is called', () {
      test('then creates correct Part type', () {
        // Given text part
        final textProto = pb.Part()..text = 'Hello';

        // When
        final textPart = Part.fromProto(textProto);

        // Then
        expect(textPart.text, equals('Hello'));
        expect(textPart.functionCall, isNull);

        // Given function call part
        final funcProto = pb.Part()
          ..functionCall = (pb.FunctionCall()
            ..name = 'test_func'
            ..args = structpb.Struct());

        // When
        final funcPart = Part.fromProto(funcProto);

        // Then
        expect(funcPart.text, isNull);
        expect(funcPart.functionCall?.name, equals('test_func'));
      });

      test('handles empty proto', () {
        // Given
        final emptyProto = pb.Part();

        // When
        final part = Part.fromProto(emptyProto);

        // Then
        expect(part.text, isNull);
        expect(part.functionCall, isNull);
      });
    });

    group('when build is called', () {
      test('builds protobuf with text', () {
        // Given
        const part = Part(text: 'Hello world');

        // When
        final proto = part.build();

        // Then
        expect(proto.hasText(), isTrue);
        expect(proto.text, equals('Hello world'));
        expect(proto.hasFunctionCall(), isFalse);
      });

      test('builds protobuf with function call', () {
        // Given
        const functionCall = FunctionCall(
          name: 'search',
          args: Struct(fields: {'query': 'Flutter'}),
        );
        const part = Part(functionCall: functionCall);

        // When
        final proto = part.build();

        // Then
        expect(proto.hasFunctionCall(), isTrue);
        expect(proto.functionCall.name, equals('search'));
        expect(proto.functionCall.args.fields['query']?.stringValue, equals('Flutter'));
        expect(proto.hasText(), isFalse);
      });

      test('builds protobuf with null text', () {
        // Given
        const part = Part(text: null);

        // When
        final proto = part.build();

        // Then
        expect(proto.hasText(), isFalse);
        expect(proto.hasFunctionCall(), isFalse);
      });

      test('builds protobuf with null function call', () {
        // Given
        const part = Part(functionCall: null);

        // When
        final proto = part.build();

        // Then
        expect(proto.hasFunctionCall(), isFalse);
        expect(proto.hasText(), isFalse);
      });

      test('builds protobuf with both text and function call (oneof constraint)', () {
        // Given - Note: protobuf Part uses oneof, so only functionCall will be set
        const functionCall = FunctionCall(
          name: 'test',
          args: Struct(fields: {}),
        );
        const part = Part(
          text: 'Some text',
          functionCall: functionCall,
        );

        // When
        final proto = part.build();

        // Then - Due to oneof constraint, only functionCall is set when both are provided
        expect(proto.text, equals('')); // text is cleared due to oneof
        expect(proto.hasFunctionCall(), isTrue);
        expect(proto.functionCall.name, equals('test'));
      });

      test('builds protobuf with neither text nor function call', () {
        // Given
        const part = Part();

        // When
        final proto = part.build();

        // Then
        expect(proto.hasText(), isFalse);
        expect(proto.hasFunctionCall(), isFalse);
      });
    });

    group('when created with both text and function call', () {
      test('then both are accessible', () {
        // Given
        const functionCall = FunctionCall(
          name: 'calculate',
          args: Struct(fields: {'expression': '2+2'}),
        );
        const part = Part(
          text: 'Calculating...',
          functionCall: functionCall,
        );

        // Then
        expect(part.text, equals('Calculating...'));
        expect(part.functionCall, equals(functionCall));
        expect(part.functionCall?.name, equals('calculate'));
      });
    });

    group('when created with no parameters', () {
      test('then both fields are null', () {
        // Given
        const part = Part();

        // Then
        expect(part.text, isNull);
        expect(part.functionCall, isNull);
      });
    });
  });
}