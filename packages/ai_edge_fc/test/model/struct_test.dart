import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/struct.dart';
import 'package:ai_edge_fc/src/proto/google/protobuf/struct.pb.dart'
    as structpb;

void main() {
  group('Struct', () {
    group('when created with various field types', () {
      test('then stores all types correctly', () {
        // Given
        const struct = Struct(
          fields: {
            'null_value': null,
            'bool_value': true,
            'number_value': 42.5,
            'string_value': 'hello',
            'list_value': [1, 'two', true],
            'struct_value': {'nested': 'value'},
          },
        );

        // Then
        expect(struct.fields['null_value'], isNull);
        expect(struct.fields['bool_value'], isTrue);
        expect(struct.fields['number_value'], equals(42.5));
        expect(struct.fields['string_value'], equals('hello'));
        expect(struct.fields['list_value'], equals([1, 'two', true]));
        expect(struct.fields['struct_value'], equals({'nested': 'value'}));
      });
    });

    group('when fromProto is called', () {
      test('then correctly converts protobuf to Dart types', () {
        // Given
        final proto = structpb.Struct()
          ..fields.addAll({
            'name': structpb.Value()..stringValue = 'John',
            'age': structpb.Value()..numberValue = 30,
            'active': structpb.Value()..boolValue = true,
            'score': structpb.Value()
              ..nullValue = structpb.NullValue.NULL_VALUE,
          });

        // When
        final struct = Struct.fromProto(proto);

        // Then
        expect(struct.fields['name'], equals('John'));
        expect(struct.fields['age'], equals(30.0));
        expect(struct.fields['active'], isTrue);
        expect(struct.fields['score'], isNull);
      });
    });

    group('when build is called', () {
      test('then generates correct protobuf', () {
        // Given
        const struct = Struct(
          fields: {
            'text': 'Hello',
            'number': 123,
            'flag': false,
            'nothing': null,
            'items': ['a', 'b', 'c'],
            'nested': {'key': 'value'},
          },
        );

        // When
        final proto = struct.build();

        // Then
        expect(proto.fields['text']?.stringValue, equals('Hello'));
        expect(proto.fields['number']?.numberValue, equals(123.0));
        expect(proto.fields['flag']?.boolValue, isFalse);
        expect(proto.fields['nothing']?.hasNullValue(), isTrue);
        expect(proto.fields['items']?.listValue.values.length, equals(3));
        expect(
          proto.fields['nested']?.structValue.fields['key']?.stringValue,
          equals('value'),
        );
      });
    });

    group('when created from Map', () {
      test('then creates Struct with Map fields', () {
        // Given
        final map = {
          'id': 1,
          'name': 'Test',
          'tags': ['tag1', 'tag2'],
        };

        // When
        final struct = Struct(fields: map);

        // Then
        expect(struct.fields['id'], equals(1));
        expect(struct.fields['name'], equals('Test'));
        expect(struct.fields['tags'], equals(['tag1', 'tag2']));
      });
    });
  });
}
