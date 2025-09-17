import 'package:ai_edge_fc/src/model/function_property.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PropertyType', () {
    test('should map to correct Protocol Buffer types', () {
      expect(PropertyType.string.pbType, equals(pb.Type.STRING));
      expect(PropertyType.number.pbType, equals(pb.Type.NUMBER));
      expect(PropertyType.integer.pbType, equals(pb.Type.INTEGER));
      expect(PropertyType.boolean.pbType, equals(pb.Type.BOOLEAN));
      expect(PropertyType.object.pbType, equals(pb.Type.OBJECT));
      expect(PropertyType.array.pbType, equals(pb.Type.ARRAY));
    });

    test('should have all expected enum values', () {
      final values = PropertyType.values;
      expect(values, hasLength(6));
      expect(values, contains(PropertyType.string));
      expect(values, contains(PropertyType.number));
      expect(values, contains(PropertyType.integer));
      expect(values, contains(PropertyType.boolean));
      expect(values, contains(PropertyType.object));
      expect(values, contains(PropertyType.array));
    });

    test('should maintain correct order', () {
      final values = PropertyType.values;
      expect(values[0], equals(PropertyType.string));
      expect(values[1], equals(PropertyType.number));
      expect(values[2], equals(PropertyType.integer));
      expect(values[3], equals(PropertyType.boolean));
      expect(values[4], equals(PropertyType.object));
      expect(values[5], equals(PropertyType.array));
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
        expect(property.type, equals(PropertyType.string));
        expect(property.description, equals('User input'));
        expect(property.required, isFalse);
      });
    });

    group('when created with all parameters', () {
      test('then all values are set', () {
        // Given
        const property = FunctionProperty(
          name: 'count',
          type: PropertyType.number,
          description: 'Item count',
          required: true,
        );

        // Then
        expect(property.name, equals('count'));
        expect(property.type, equals(PropertyType.number));
        expect(property.description, equals('Item count'));
        expect(property.required, isTrue);
      });
    });

    group('when created with different types', () {
      test('then each type is correctly assigned', () {
        // String type
        const stringProp = FunctionProperty(
          name: 'text',
          type: PropertyType.string,
          description: 'Text input',
        );
        expect(stringProp.type, equals(PropertyType.string));

        // Number type
        const numberProp = FunctionProperty(
          name: 'price',
          type: PropertyType.number,
          description: 'Product price',
        );
        expect(numberProp.type, equals(PropertyType.number));

        // Integer type
        const integerProp = FunctionProperty(
          name: 'count',
          type: PropertyType.integer,
          description: 'Item count',
        );
        expect(integerProp.type, equals(PropertyType.integer));

        // Boolean type
        const booleanProp = FunctionProperty(
          name: 'enabled',
          type: PropertyType.boolean,
          description: 'Feature flag',
        );
        expect(booleanProp.type, equals(PropertyType.boolean));

        // Object type
        const objectProp = FunctionProperty(
          name: 'config',
          type: PropertyType.object,
          description: 'Configuration object',
        );
        expect(objectProp.type, equals(PropertyType.object));

        // Array type
        const arrayProp = FunctionProperty(
          name: 'items',
          type: PropertyType.array,
          description: 'List of items',
        );
        expect(arrayProp.type, equals(PropertyType.array));
      });
    });

    group('when build is called', () {
      test('then returns correct MapEntry with string type', () {
        // Given
        const property = FunctionProperty(
          name: 'username',
          type: PropertyType.string,
          description: 'User name',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('username'));
        expect(entry.value.type, equals(pb.Type.STRING));
        expect(entry.value.description, equals('User name'));
      });

      test('then returns correct MapEntry with number type', () {
        // Given
        const property = FunctionProperty(
          name: 'price',
          type: PropertyType.number,
          description: 'Product price',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('price'));
        expect(entry.value.type, equals(pb.Type.NUMBER));
        expect(entry.value.description, equals('Product price'));
      });

      test('then returns correct MapEntry with integer type', () {
        // Given
        const property = FunctionProperty(
          name: 'quantity',
          type: PropertyType.integer,
          description: 'Item quantity',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('quantity'));
        expect(entry.value.type, equals(pb.Type.INTEGER));
        expect(entry.value.description, equals('Item quantity'));
      });

      test('then returns correct MapEntry with boolean type', () {
        // Given
        const property = FunctionProperty(
          name: 'enabled',
          type: PropertyType.boolean,
          description: 'Enable feature',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('enabled'));
        expect(entry.value.type, equals(pb.Type.BOOLEAN));
        expect(entry.value.description, equals('Enable feature'));
      });

      test('then returns correct MapEntry with object type', () {
        // Given
        const property = FunctionProperty(
          name: 'metadata',
          type: PropertyType.object,
          description: 'Additional metadata',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('metadata'));
        expect(entry.value.type, equals(pb.Type.OBJECT));
        expect(entry.value.description, equals('Additional metadata'));
      });

      test('then returns correct MapEntry with array type', () {
        // Given
        const property = FunctionProperty(
          name: 'tags',
          type: PropertyType.array,
          description: 'List of tags',
        );

        // When
        final entry = property.build();

        // Then
        expect(entry.key, equals('tags'));
        expect(entry.value.type, equals(pb.Type.ARRAY));
        expect(entry.value.description, equals('List of tags'));
      });
    });
  });
}
