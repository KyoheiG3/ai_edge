import 'package:ai_edge_fc/src/model/function_call.dart';
import 'package:ai_edge_fc/src/model/struct.dart';
import 'package:ai_edge_fc/src/proto/google/protobuf/struct.pb.dart'
    as structpb;
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FunctionCall', () {
    group('when created', () {
      test('then properties are set', () {
        // Given
        const call = FunctionCall(
          name: 'get_weather',
          args: Struct(fields: {'location': 'Tokyo'}),
        );

        // Then
        expect(call.name, equals('get_weather'));
        expect(call.args.fields['location'], equals('Tokyo'));
      });
    });

    group('when fromProto is called', () {
      test('then creates instance from protobuf', () {
        // Given
        final proto = pb.FunctionCall()
          ..name = 'calculate'
          ..args = (structpb.Struct()
            ..fields.addAll({
              'x': structpb.Value()..numberValue = 10,
              'y': structpb.Value()..numberValue = 20,
            }));

        // When
        final call = FunctionCall.fromProto(proto);

        // Then
        expect(call.name, equals('calculate'));
        expect(call.args.fields['x'], equals(10.0));
        expect(call.args.fields['y'], equals(20.0));
      });
    });
  });
}
