import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/function_declaration.dart';
import 'package:ai_edge_fc/src/model/function_property.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;

void main() {
  group('FunctionDeclaration', () {
    group('when created with minimal parameters', () {
      test('then required fields are set', () {
        // Given
        const function = FunctionDeclaration(
          name: 'get_weather',
          properties: [],
        );

        // Then
        expect(function.name, equals('get_weather'));
        expect(function.description, isNull);
        expect(function.properties, isEmpty);
      });
    });

    group('when created with all parameters', () {
      test('then all fields are set correctly', () {
        // Given
        final function = const FunctionDeclaration(
          name: 'calculate',
          description: 'Perform mathematical calculations',
          properties: [
            FunctionProperty(
              name: 'expression',
              description: 'Math expression to evaluate',
              required: true,
            ),
          ],
        );

        // Then
        expect(function.name, equals('calculate'));
        expect(
          function.description,
          equals('Perform mathematical calculations'),
        );
        expect(function.properties.length, equals(1));
        expect(function.properties.first.name, equals('expression'));
      });
    });

    group('when build is called with properties', () {
      test('then generates correct protobuf', () {
        // Given
        const function = FunctionDeclaration(
          name: 'search',
          description: 'Search for information',
          properties: [
            FunctionProperty(
              name: 'query',
              description: 'Search query',
              required: true,
            ),
            FunctionProperty(
              name: 'limit',
              type: pb.Type.NUMBER,
              description: 'Maximum results',
              required: false,
            ),
          ],
        );

        // When
        final proto = function.build();

        // Then
        expect(proto.name, equals('search'));
        expect(proto.description, equals('Search for information'));
        expect(proto.hasParameters(), isTrue);
        expect(proto.parameters.type, equals(pb.Type.OBJECT));
        expect(proto.parameters.properties.length, equals(2));
        expect(proto.parameters.required, contains('query'));
        expect(proto.parameters.required.contains('limit'), isFalse);
      });
    });
  });

  group('FunctionProperty', () {
    group('when created with defaults', () {
      test('then uses STRING type and not required', () {
        // Given
        const property = FunctionProperty(
          name: 'input',
          description: 'User input',
        );

        // Then
        expect(property.name, equals('input'));
        expect(property.type, equals(pb.Type.STRING));
        expect(property.description, equals('User input'));
        expect(property.required, isFalse);
      });
    });

    group('when created with all parameters', () {
      test('then all values are set', () {
        // Given
        const property = FunctionProperty(
          name: 'count',
          type: pb.Type.NUMBER,
          description: 'Item count',
          required: true,
        );

        // Then
        expect(property.name, equals('count'));
        expect(property.type, equals(pb.Type.NUMBER));
        expect(property.description, equals('Item count'));
        expect(property.required, isTrue);
      });
    });

    group('when build is called', () {
      test('then returns correct MapEntry', () {
        // Given
        const property = FunctionProperty(
          name: 'enabled',
          type: pb.Type.BOOLEAN,
          description: 'Enable feature',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('enabled'));
        expect(entry.value.type, equals(pb.Type.BOOLEAN));
        expect(entry.value.description, equals('Enable feature'));
      });
    });
  });
}