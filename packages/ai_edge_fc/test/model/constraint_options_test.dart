import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/constraint_options.dart';
import 'package:ai_edge_fc/src/proto/local_agents/function_calling/core/proto/constraint_options.pb.dart'
    as pb;

void main() {
  group('ConstraintOptions', () {
    group('constructor', () {
      test('creates instance with toolCallOnly', () {
        // Given
        const toolCallOnly = ToolCallOnly(
          constraintPrefix: 'prefix',
          constraintSuffix: 'suffix',
        );

        // When
        const constraints = ConstraintOptions(toolCallOnly: toolCallOnly);

        // Then
        expect(constraints.toolCallOnly, equals(toolCallOnly));
        expect(constraints.textAndOr, isNull);
        expect(constraints.textUntil, isNull);
      });

      test('creates instance with textAndOr', () {
        // Given
        const textAndOr = TextAndOr(
          stopPhrasePrefix: 'start',
          stopPhraseSuffix: 'end',
          constraintSuffix: 'suffix',
        );

        // When
        const constraints = ConstraintOptions(textAndOr: textAndOr);

        // Then
        expect(constraints.toolCallOnly, isNull);
        expect(constraints.textAndOr, equals(textAndOr));
        expect(constraints.textUntil, isNull);
      });

      test('creates instance with textUntil', () {
        // Given
        const textUntil = TextUntil(
          stopPhrase: 'STOP',
          constraintSuffix: 'suffix',
        );

        // When
        const constraints = ConstraintOptions(textUntil: textUntil);

        // Then
        expect(constraints.toolCallOnly, isNull);
        expect(constraints.textAndOr, isNull);
        expect(constraints.textUntil, equals(textUntil));
      });

      test('creates instance with all null', () {
        // When
        const constraints = ConstraintOptions();

        // Then
        expect(constraints.toolCallOnly, isNull);
        expect(constraints.textAndOr, isNull);
        expect(constraints.textUntil, isNull);
      });
    });

    group('fromProto', () {
      test('creates instance from protobuf with toolCallOnly', () {
        // Given
        final proto = pb.ConstraintOptions()
          ..toolCallOnly = (pb.ConstraintOptions_ToolCallOnly()
            ..constraintPrefix = 'func:'
            ..constraintSuffix = '\n');

        // When
        final constraints = ConstraintOptions.fromProto(proto);

        // Then
        expect(constraints.toolCallOnly?.constraintPrefix, equals('func:'));
        expect(constraints.toolCallOnly?.constraintSuffix, equals('\n'));
        expect(constraints.textAndOr, isNull);
        expect(constraints.textUntil, isNull);
      });

      test('creates instance from protobuf with textAndOr', () {
        // Given
        final proto = pb.ConstraintOptions()
          ..textAndOr = (pb.ConstraintOptions_TextAndOr()
            ..stopPhrasePrefix = 'BEGIN'
            ..stopPhraseSuffix = 'END'
            ..constraintSuffix = '---');

        // When
        final constraints = ConstraintOptions.fromProto(proto);

        // Then
        expect(constraints.toolCallOnly, isNull);
        expect(constraints.textAndOr?.stopPhrasePrefix, equals('BEGIN'));
        expect(constraints.textAndOr?.stopPhraseSuffix, equals('END'));
        expect(constraints.textAndOr?.constraintSuffix, equals('---'));
        expect(constraints.textUntil, isNull);
      });

      test('creates instance from protobuf with textUntil', () {
        // Given
        final proto = pb.ConstraintOptions()
          ..textUntil = (pb.ConstraintOptions_TextUntil()
            ..stopPhrase = 'TERMINATE'
            ..constraintSuffix = '.');

        // When
        final constraints = ConstraintOptions.fromProto(proto);

        // Then
        expect(constraints.toolCallOnly, isNull);
        expect(constraints.textAndOr, isNull);
        expect(constraints.textUntil?.stopPhrase, equals('TERMINATE'));
        expect(constraints.textUntil?.constraintSuffix, equals('.'));
      });

      test('creates instance from empty protobuf', () {
        // Given
        final proto = pb.ConstraintOptions();

        // When
        final constraints = ConstraintOptions.fromProto(proto);

        // Then
        expect(constraints.toolCallOnly, isNull);
        expect(constraints.textAndOr, isNull);
        expect(constraints.textUntil, isNull);
      });
    });

    group('build', () {
      test('builds protobuf with toolCallOnly', () {
        // Given
        const constraints = ConstraintOptions(
          toolCallOnly: ToolCallOnly(
            constraintPrefix: 'prefix',
            constraintSuffix: 'suffix',
          ),
        );

        // When
        final proto = constraints.build();

        // Then
        expect(proto.hasToolCallOnly(), isTrue);
        expect(proto.toolCallOnly.constraintPrefix, equals('prefix'));
        expect(proto.toolCallOnly.constraintSuffix, equals('suffix'));
        expect(proto.hasTextAndOr(), isFalse);
        expect(proto.hasTextUntil(), isFalse);
      });

      test('builds protobuf with textAndOr', () {
        // Given
        const constraints = ConstraintOptions(
          textAndOr: TextAndOr(
            stopPhrasePrefix: 'start',
            stopPhraseSuffix: 'end',
            constraintSuffix: 'suffix',
          ),
        );

        // When
        final proto = constraints.build();

        // Then
        expect(proto.hasToolCallOnly(), isFalse);
        expect(proto.hasTextAndOr(), isTrue);
        expect(proto.textAndOr.stopPhrasePrefix, equals('start'));
        expect(proto.textAndOr.stopPhraseSuffix, equals('end'));
        expect(proto.textAndOr.constraintSuffix, equals('suffix'));
        expect(proto.hasTextUntil(), isFalse);
      });

      test('builds protobuf with textUntil', () {
        // Given
        const constraints = ConstraintOptions(
          textUntil: TextUntil(
            stopPhrase: 'STOP',
            constraintSuffix: 'done',
          ),
        );

        // When
        final proto = constraints.build();

        // Then
        expect(proto.hasToolCallOnly(), isFalse);
        expect(proto.hasTextAndOr(), isFalse);
        expect(proto.hasTextUntil(), isTrue);
        expect(proto.textUntil.stopPhrase, equals('STOP'));
        expect(proto.textUntil.constraintSuffix, equals('done'));
      });

      test('builds empty protobuf when all null', () {
        // Given
        const constraints = ConstraintOptions();

        // When
        final proto = constraints.build();

        // Then
        expect(proto.hasToolCallOnly(), isFalse);
        expect(proto.hasTextAndOr(), isFalse);
        expect(proto.hasTextUntil(), isFalse);
      });
    });

    group('writeToBuffer', () {
      test('serializes and deserializes correctly with toolCallOnly', () {
        // Given
        const constraints = ConstraintOptions(
          toolCallOnly: ToolCallOnly(
            constraintPrefix: 'test:',
            constraintSuffix: ';',
          ),
        );

        // When
        final buffer = constraints.writeToBuffer();
        final decoded = pb.ConstraintOptions.fromBuffer(buffer);

        // Then
        expect(decoded.hasToolCallOnly(), isTrue);
        expect(decoded.toolCallOnly.constraintPrefix, equals('test:'));
        expect(decoded.toolCallOnly.constraintSuffix, equals(';'));
      });
    });
  });

  group('ToolCallOnly', () {
    group('constructor', () {
      test('creates instance with all parameters', () {
        // When
        const toolCallOnly = ToolCallOnly(
          constraintPrefix: 'prefix',
          constraintSuffix: 'suffix',
        );

        // Then
        expect(toolCallOnly.constraintPrefix, equals('prefix'));
        expect(toolCallOnly.constraintSuffix, equals('suffix'));
      });

      test('creates instance with null parameters', () {
        // When
        const toolCallOnly = ToolCallOnly();

        // Then
        expect(toolCallOnly.constraintPrefix, isNull);
        expect(toolCallOnly.constraintSuffix, isNull);
      });

      test('creates instance with only prefix', () {
        // When
        const toolCallOnly = ToolCallOnly(constraintPrefix: 'prefix');

        // Then
        expect(toolCallOnly.constraintPrefix, equals('prefix'));
        expect(toolCallOnly.constraintSuffix, isNull);
      });

      test('creates instance with only suffix', () {
        // When
        const toolCallOnly = ToolCallOnly(constraintSuffix: 'suffix');

        // Then
        expect(toolCallOnly.constraintPrefix, isNull);
        expect(toolCallOnly.constraintSuffix, equals('suffix'));
      });
    });

    group('fromProto', () {
      test('creates instance from protobuf with all fields', () {
        // Given
        final proto = pb.ConstraintOptions_ToolCallOnly()
          ..constraintPrefix = 'start'
          ..constraintSuffix = 'end';

        // When
        final toolCallOnly = ToolCallOnly.fromProto(proto);

        // Then
        expect(toolCallOnly.constraintPrefix, equals('start'));
        expect(toolCallOnly.constraintSuffix, equals('end'));
      });

      test('creates instance from protobuf with empty fields', () {
        // Given
        final proto = pb.ConstraintOptions_ToolCallOnly();

        // When
        final toolCallOnly = ToolCallOnly.fromProto(proto);

        // Then
        expect(toolCallOnly.constraintPrefix, isEmpty);
        expect(toolCallOnly.constraintSuffix, isEmpty);
      });

      test('creates instance from protobuf with only prefix', () {
        // Given
        final proto = pb.ConstraintOptions_ToolCallOnly()
          ..constraintPrefix = 'prefix';

        // When
        final toolCallOnly = ToolCallOnly.fromProto(proto);

        // Then
        expect(toolCallOnly.constraintPrefix, equals('prefix'));
        expect(toolCallOnly.constraintSuffix, isEmpty);
      });
    });

    group('build', () {
      test('builds protobuf with all fields', () {
        // Given
        const toolCallOnly = ToolCallOnly(
          constraintPrefix: 'pre',
          constraintSuffix: 'suf',
        );

        // When
        final proto = toolCallOnly.build();

        // Then
        expect(proto.constraintPrefix, equals('pre'));
        expect(proto.constraintSuffix, equals('suf'));
      });

      test('builds protobuf with null fields', () {
        // Given
        const toolCallOnly = ToolCallOnly();

        // When
        final proto = toolCallOnly.build();

        // Then
        expect(proto.constraintPrefix, isEmpty);
        expect(proto.constraintSuffix, isEmpty);
      });
    });
  });

  group('TextAndOr', () {
    group('constructor', () {
      test('creates instance with all parameters', () {
        // When
        const textAndOr = TextAndOr(
          stopPhrasePrefix: 'start',
          stopPhraseSuffix: 'end',
          constraintSuffix: 'suffix',
        );

        // Then
        expect(textAndOr.stopPhrasePrefix, equals('start'));
        expect(textAndOr.stopPhraseSuffix, equals('end'));
        expect(textAndOr.constraintSuffix, equals('suffix'));
      });

      test('creates instance with null parameters', () {
        // When
        const textAndOr = TextAndOr();

        // Then
        expect(textAndOr.stopPhrasePrefix, isNull);
        expect(textAndOr.stopPhraseSuffix, isNull);
        expect(textAndOr.constraintSuffix, isNull);
      });

      test('creates instance with partial parameters', () {
        // When
        const textAndOr = TextAndOr(
          stopPhrasePrefix: 'start',
          constraintSuffix: 'suffix',
        );

        // Then
        expect(textAndOr.stopPhrasePrefix, equals('start'));
        expect(textAndOr.stopPhraseSuffix, isNull);
        expect(textAndOr.constraintSuffix, equals('suffix'));
      });
    });

    group('fromProto', () {
      test('creates instance from protobuf with all fields', () {
        // Given
        final proto = pb.ConstraintOptions_TextAndOr()
          ..stopPhrasePrefix = 'BEGIN'
          ..stopPhraseSuffix = 'END'
          ..constraintSuffix = 'DONE';

        // When
        final textAndOr = TextAndOr.fromProto(proto);

        // Then
        expect(textAndOr.stopPhrasePrefix, equals('BEGIN'));
        expect(textAndOr.stopPhraseSuffix, equals('END'));
        expect(textAndOr.constraintSuffix, equals('DONE'));
      });

      test('creates instance from protobuf with empty fields', () {
        // Given
        final proto = pb.ConstraintOptions_TextAndOr();

        // When
        final textAndOr = TextAndOr.fromProto(proto);

        // Then
        expect(textAndOr.stopPhrasePrefix, isEmpty);
        expect(textAndOr.stopPhraseSuffix, isEmpty);
        expect(textAndOr.constraintSuffix, isEmpty);
      });

      test('creates instance from protobuf with partial fields', () {
        // Given
        final proto = pb.ConstraintOptions_TextAndOr()
          ..stopPhraseSuffix = 'END';

        // When
        final textAndOr = TextAndOr.fromProto(proto);

        // Then
        expect(textAndOr.stopPhrasePrefix, isEmpty);
        expect(textAndOr.stopPhraseSuffix, equals('END'));
        expect(textAndOr.constraintSuffix, isEmpty);
      });
    });

    group('build', () {
      test('builds protobuf with all fields', () {
        // Given
        const textAndOr = TextAndOr(
          stopPhrasePrefix: 'pre',
          stopPhraseSuffix: 'suf',
          constraintSuffix: 'con',
        );

        // When
        final proto = textAndOr.build();

        // Then
        expect(proto.stopPhrasePrefix, equals('pre'));
        expect(proto.stopPhraseSuffix, equals('suf'));
        expect(proto.constraintSuffix, equals('con'));
      });

      test('builds protobuf with null fields', () {
        // Given
        const textAndOr = TextAndOr();

        // When
        final proto = textAndOr.build();

        // Then
        expect(proto.stopPhrasePrefix, isEmpty);
        expect(proto.stopPhraseSuffix, isEmpty);
        expect(proto.constraintSuffix, isEmpty);
      });

      test('builds protobuf with partial fields', () {
        // Given
        const textAndOr = TextAndOr(
          stopPhrasePrefix: 'pre',
        );

        // When
        final proto = textAndOr.build();

        // Then
        expect(proto.stopPhrasePrefix, equals('pre'));
        expect(proto.stopPhraseSuffix, isEmpty);
        expect(proto.constraintSuffix, isEmpty);
      });
    });
  });

  group('TextUntil', () {
    group('constructor', () {
      test('creates instance with all parameters', () {
        // When
        const textUntil = TextUntil(
          stopPhrase: 'STOP',
          constraintSuffix: 'suffix',
        );

        // Then
        expect(textUntil.stopPhrase, equals('STOP'));
        expect(textUntil.constraintSuffix, equals('suffix'));
      });

      test('creates instance with null parameters', () {
        // When
        const textUntil = TextUntil();

        // Then
        expect(textUntil.stopPhrase, isNull);
        expect(textUntil.constraintSuffix, isNull);
      });

      test('creates instance with only stopPhrase', () {
        // When
        const textUntil = TextUntil(stopPhrase: 'STOP');

        // Then
        expect(textUntil.stopPhrase, equals('STOP'));
        expect(textUntil.constraintSuffix, isNull);
      });

      test('creates instance with only constraintSuffix', () {
        // When
        const textUntil = TextUntil(constraintSuffix: 'suffix');

        // Then
        expect(textUntil.stopPhrase, isNull);
        expect(textUntil.constraintSuffix, equals('suffix'));
      });
    });

    group('fromProto', () {
      test('creates instance from protobuf with all fields', () {
        // Given
        final proto = pb.ConstraintOptions_TextUntil()
          ..stopPhrase = 'HALT'
          ..constraintSuffix = 'END';

        // When
        final textUntil = TextUntil.fromProto(proto);

        // Then
        expect(textUntil.stopPhrase, equals('HALT'));
        expect(textUntil.constraintSuffix, equals('END'));
      });

      test('creates instance from protobuf with empty fields', () {
        // Given
        final proto = pb.ConstraintOptions_TextUntil();

        // When
        final textUntil = TextUntil.fromProto(proto);

        // Then
        expect(textUntil.stopPhrase, isEmpty);
        expect(textUntil.constraintSuffix, isEmpty);
      });

      test('creates instance from protobuf with only stopPhrase', () {
        // Given
        final proto = pb.ConstraintOptions_TextUntil()
          ..stopPhrase = 'STOP';

        // When
        final textUntil = TextUntil.fromProto(proto);

        // Then
        expect(textUntil.stopPhrase, equals('STOP'));
        expect(textUntil.constraintSuffix, isEmpty);
      });

      test('creates instance from protobuf with only constraintSuffix', () {
        // Given
        final proto = pb.ConstraintOptions_TextUntil()
          ..constraintSuffix = 'suffix';

        // When
        final textUntil = TextUntil.fromProto(proto);

        // Then
        expect(textUntil.stopPhrase, isEmpty);
        expect(textUntil.constraintSuffix, equals('suffix'));
      });
    });

    group('build', () {
      test('builds protobuf with all fields', () {
        // Given
        const textUntil = TextUntil(
          stopPhrase: 'STOP',
          constraintSuffix: 'suf',
        );

        // When
        final proto = textUntil.build();

        // Then
        expect(proto.stopPhrase, equals('STOP'));
        expect(proto.constraintSuffix, equals('suf'));
      });

      test('builds protobuf with null fields', () {
        // Given
        const textUntil = TextUntil();

        // When
        final proto = textUntil.build();

        // Then
        expect(proto.stopPhrase, isEmpty);
        expect(proto.constraintSuffix, isEmpty);
      });

      test('builds protobuf with only stopPhrase', () {
        // Given
        const textUntil = TextUntil(stopPhrase: 'STOP');

        // When
        final proto = textUntil.build();

        // Then
        expect(proto.stopPhrase, equals('STOP'));
        expect(proto.constraintSuffix, isEmpty);
      });
    });
  });

  group('Integration tests', () {
    test('round-trip conversion maintains data integrity', () {
      // Given
      const original = ConstraintOptions(
        toolCallOnly: ToolCallOnly(
          constraintPrefix: 'Function: ',
          constraintSuffix: '\n',
        ),
      );

      // When
      final proto = original.build();
      final restored = ConstraintOptions.fromProto(proto);

      // Then
      expect(restored.toolCallOnly?.constraintPrefix, 
             equals(original.toolCallOnly?.constraintPrefix));
      expect(restored.toolCallOnly?.constraintSuffix,
             equals(original.toolCallOnly?.constraintSuffix));
    });

    test('multiple constraint types can be built independently', () {
      // Given
      const constraints1 = ConstraintOptions(
        toolCallOnly: ToolCallOnly(constraintPrefix: 'func'),
      );
      const constraints2 = ConstraintOptions(
        textAndOr: TextAndOr(stopPhrasePrefix: 'stop'),
      );
      const constraints3 = ConstraintOptions(
        textUntil: TextUntil(stopPhrase: 'END'),
      );

      // When
      final proto1 = constraints1.build();
      final proto2 = constraints2.build();
      final proto3 = constraints3.build();

      // Then
      expect(proto1.hasToolCallOnly(), isTrue);
      expect(proto1.hasTextAndOr(), isFalse);
      expect(proto1.hasTextUntil(), isFalse);

      expect(proto2.hasToolCallOnly(), isFalse);
      expect(proto2.hasTextAndOr(), isTrue);
      expect(proto2.hasTextUntil(), isFalse);

      expect(proto3.hasToolCallOnly(), isFalse);
      expect(proto3.hasTextAndOr(), isFalse);
      expect(proto3.hasTextUntil(), isTrue);
    });
  });
}