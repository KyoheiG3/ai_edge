import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edge_fc/src/model/generate_content_response.dart' as gen;
import 'package:ai_edge_fc/src/model/content.dart';
import 'package:ai_edge_fc/src/model/part.dart';
import 'package:ai_edge_fc/src/model/function_call.dart';
import 'package:ai_edge_fc/src/model/struct.dart';
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/content.pb.dart'
    as pb;
import 'package:ai_edge_fc/src/proto/local_agents/core/proto/generative_service.pb.dart'
    as genpb;
import 'package:ai_edge_fc/src/proto/google/protobuf/struct.pb.dart'
    as structpb;

void main() {
  group('GenerateContentResponse', () {
    group('when fromBuffer is called', () {
      test('then creates instance from binary', () {
        // Given - create a simple protobuf response
        final proto = genpb.GenerateContentResponse()
          ..candidates.add(
            genpb.Candidate()
              ..content = (pb.Content()
                ..role = 'model'
                ..parts.add(pb.Part()..text = 'Response')),
          );
        final buffer = proto.writeToBuffer();

        // When
        final response = gen.GenerateContentResponse.fromBuffer(buffer);

        // Then
        expect(response.candidates.length, equals(1));
        expect(response.candidates.first.content?.role, equals('model'));
      });
    });

    group('when extracting function calls', () {
      test('then finds function call in parts', () {
        // Given - create a response with function call
        final proto = genpb.GenerateContentResponse()
          ..candidates.add(
            genpb.Candidate()
              ..content = (pb.Content()
                ..role = 'model'
                ..parts.addAll([
                  pb.Part()..text = 'Let me help',
                  pb.Part()
                    ..functionCall = (pb.FunctionCall()
                      ..name = 'search'
                      ..args = (structpb.Struct()
                        ..fields['query'] = (structpb.Value()
                          ..stringValue = 'test'))),
                ])),
          );
        final response = gen.GenerateContentResponse.fromProto(proto);

        // When checking for function calls
        final candidate = response.candidates.first;
        final parts = candidate.content?.parts ?? [];
        FunctionCall? functionCall;
        for (final part in parts) {
          if (part.functionCall != null) {
            functionCall = part.functionCall;
            break;
          }
        }

        // Then
        expect(functionCall?.name, equals('search'));
        expect(functionCall?.args.fields['query'], equals('test'));
      });
    });

    group('when no function calls present', () {
      test('then no function call found', () {
        // Given
        final proto = genpb.GenerateContentResponse()
          ..candidates.add(
            genpb.Candidate()
              ..content = (pb.Content()
                ..role = 'model'
                ..parts.add(pb.Part()..text = 'Just text')),
          );
        final response = gen.GenerateContentResponse.fromProto(proto);

        // When checking for function calls
        final candidate = response.candidates.first;
        final parts = candidate.content?.parts ?? [];
        FunctionCall? functionCall;
        for (final part in parts) {
          if (part.functionCall != null) {
            functionCall = part.functionCall;
            break;
          }
        }

        // Then
        expect(functionCall, isNull);
      });
    });

    group('text getter', () {
      test('returns text from first part when available', () {
        // Given
        final proto = genpb.GenerateContentResponse()
          ..candidates.add(
            genpb.Candidate()
              ..content = (pb.Content()
                ..role = 'model'
                ..parts.add(pb.Part()..text = 'Hello, world!')),
          );
        final response = gen.GenerateContentResponse.fromProto(proto);

        // When
        final text = response.text;

        // Then
        expect(text, equals('Hello, world!'));
      });

      test('returns null when no candidates', () {
        // Given
        const response = gen.GenerateContentResponse(candidates: []);

        // When
        final text = response.text;

        // Then
        expect(text, isNull);
      });

      test('returns null when candidate has no content', () {
        // Given
        const response = gen.GenerateContentResponse(
          candidates: [gen.Candidate(content: null)],
        );

        // When
        final text = response.text;

        // Then
        expect(text, isNull);
      });

      test('returns null when content has no parts', () {
        // Given
        const response = gen.GenerateContentResponse(
          candidates: [
            gen.Candidate(
              content: Content(role: 'model', parts: []),
            ),
          ],
        );

        // When
        final text = response.text;

        // Then
        expect(text, isNull);
      });

      test('returns null when first part has no text', () {
        // Given
        final response = gen.GenerateContentResponse(
          candidates: [
            gen.Candidate(
              content: Content(
                role: 'model',
                parts: [
                  Part(
                    functionCall: const FunctionCall(
                      name: 'test',
                      args: Struct(fields: {}),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        // When
        final text = response.text;

        // Then
        expect(text, isNull);
      });
    });

    group('functionCall getter', () {
      test('returns functionCall from first part when available', () {
        // Given
        const expectedCall = FunctionCall(
          name: 'getData',
          args: Struct(fields: {'id': '123'}),
        );
        final response = gen.GenerateContentResponse(
          candidates: [
            gen.Candidate(
              content: Content(
                role: 'model',
                parts: [Part(functionCall: expectedCall)],
              ),
            ),
          ],
        );

        // When
        final functionCall = response.functionCall;

        // Then
        expect(functionCall, equals(expectedCall));
        expect(functionCall?.name, equals('getData'));
      });

      test('returns null when no candidates', () {
        // Given
        const response = gen.GenerateContentResponse(candidates: []);

        // When
        final functionCall = response.functionCall;

        // Then
        expect(functionCall, isNull);
      });

      test('returns null when candidate has no content', () {
        // Given
        const response = gen.GenerateContentResponse(
          candidates: [gen.Candidate(content: null)],
        );

        // When
        final functionCall = response.functionCall;

        // Then
        expect(functionCall, isNull);
      });

      test('returns null when content has no parts', () {
        // Given
        const response = gen.GenerateContentResponse(
          candidates: [
            gen.Candidate(
              content: Content(role: 'model', parts: []),
            ),
          ],
        );

        // When
        final functionCall = response.functionCall;

        // Then
        expect(functionCall, isNull);
      });

      test('returns null when first part has no functionCall', () {
        // Given
        const response = gen.GenerateContentResponse(
          candidates: [
            gen.Candidate(
              content: Content(
                role: 'model',
                parts: [Part(text: 'Just text')],
              ),
            ),
          ],
        );

        // When
        final functionCall = response.functionCall;

        // Then
        expect(functionCall, isNull);
      });
    });

    group('multiple candidates', () {
      test('getters use first candidate', () {
        // Given
        final response = gen.GenerateContentResponse(
          candidates: [
            gen.Candidate(
              content: Content(
                role: 'model',
                parts: [Part(text: 'First response')],
              ),
            ),
            gen.Candidate(
              content: Content(
                role: 'model',
                parts: [Part(text: 'Second response')],
              ),
            ),
          ],
        );

        // When
        final text = response.text;

        // Then
        expect(text, equals('First response'));
        expect(response.candidates.length, equals(2));
      });
    });

    group('Candidate', () {
      test('fromProto handles missing content', () {
        // Given
        final proto = genpb.Candidate();

        // When
        final candidate = gen.Candidate.fromProto(proto);

        // Then
        expect(candidate.content, isNull);
      });

      test('fromProto handles present content', () {
        // Given
        final proto = genpb.Candidate()
          ..content = (pb.Content()
            ..role = 'user'
            ..parts.add(pb.Part()..text = 'Test'));

        // When
        final candidate = gen.Candidate.fromProto(proto);

        // Then
        expect(candidate.content, isNotNull);
        expect(candidate.content?.role, equals('user'));
        expect(candidate.content?.parts.first.text, equals('Test'));
      });

      test('constructor sets content property', () {
        // Given
        const content = Content(role: 'assistant', parts: []);

        // When
        const candidate = gen.Candidate(content: content);

        // Then
        expect(candidate.content, equals(content));
        expect(candidate.content?.role, equals('assistant'));
      });
    });

    group('constructor', () {
      test('creates instance with candidates', () {
        // Given
        const candidates = [
          gen.Candidate(
            content: Content(role: 'model', parts: []),
          ),
          gen.Candidate(
            content: Content(role: 'model', parts: []),
          ),
        ];

        // When
        const response = gen.GenerateContentResponse(candidates: candidates);

        // Then
        expect(response.candidates, equals(candidates));
        expect(response.candidates.length, equals(2));
      });

      test('handles empty candidates list', () {
        // Given & When
        const response = gen.GenerateContentResponse(candidates: []);

        // Then
        expect(response.candidates, isEmpty);
        expect(response.text, isNull);
        expect(response.functionCall, isNull);
      });
    });
  });
}
