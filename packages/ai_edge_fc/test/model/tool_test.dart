import 'package:ai_edge_fc/src/model/function_declaration.dart';
import 'package:ai_edge_fc/src/model/tool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tool', () {
    group('when created with function declarations', () {
      test('then functions are stored', () {
        // Given
        const tool = Tool(
          functionDeclarations: [
            FunctionDeclaration(name: 'func1', properties: []),
            FunctionDeclaration(name: 'func2', properties: []),
          ],
        );

        // Then
        expect(tool.functionDeclarations.length, equals(2));
        expect(tool.functionDeclarations[0].name, equals('func1'));
        expect(tool.functionDeclarations[1].name, equals('func2'));
      });
    });

    group('when build is called', () {
      test('then generates correct protobuf', () {
        // Given
        const tool = Tool(
          functionDeclarations: [
            FunctionDeclaration(
              name: 'test_func',
              description: 'Test function',
              properties: [],
            ),
          ],
        );

        // When
        final proto = tool.build();

        // Then
        expect(proto.functionDeclarations.length, equals(1));
        expect(proto.functionDeclarations.first.name, equals('test_func'));
        expect(
          proto.functionDeclarations.first.description,
          equals('Test function'),
        );
      });
    });

    group('when created with empty declarations', () {
      test('then has empty list', () {
        // Given
        const tool = Tool(functionDeclarations: []);

        // Then
        expect(tool.functionDeclarations, isEmpty);
      });
    });
  });
}
