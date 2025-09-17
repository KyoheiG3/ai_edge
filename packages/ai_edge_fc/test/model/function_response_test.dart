import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/function_response.dart';
import 'package:ai_edge_fc/src/model/function_call.dart';
import 'package:ai_edge_fc/src/model/struct.dart';

void main() {
  group('FunctionResponse', () {
    group('when created', () {
      test('then properties are set', () {
        // Given
        const functionCall = FunctionCall(
          name: 'test',
          args: Struct(fields: {}),
        );
        final response = FunctionResponse(
          role: 'function',
          functionCall: functionCall,
          response: {'result': 'success'},
        );

        // Then
        expect(response.role, equals('function'));
        expect(response.functionCall.name, equals('test'));
        expect(response.response['result'], equals('success'));
      });
    });

    group('when build is called', () {
      test('then generates correct Content protobuf', () {
        // Given
        const functionCall = FunctionCall(
          name: 'get_data',
          args: Struct(fields: {'id': '123'}),
        );
        final response = FunctionResponse(
          functionCall: functionCall,
          response: {'data': 'test data'},
        );

        // When
        final proto = response.build();

        // Then
        expect(proto.role, equals('')); // protobuf strings default to empty
        expect(proto.parts.length, equals(1));
        expect(proto.parts.first.hasFunctionResponse(), isTrue);
        expect(proto.parts.first.functionResponse.name, equals('get_data'));
      });
    });
  });
}
