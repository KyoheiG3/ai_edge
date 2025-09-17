// This is a generated file - do not edit.
//
// Generated from local_agents/core/proto/generative_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use generateContentRequestDescriptor instead')
const GenerateContentRequest$json = {
  '1': 'GenerateContentRequest',
  '2': [
    {'1': 'model', '3': 1, '4': 1, '5': 9, '10': 'model'},
    {
      '1': 'system_instruction',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Content',
      '9': 0,
      '10': 'systemInstruction',
      '17': true
    },
    {
      '1': 'contents',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Content',
      '10': 'contents'
    },
    {
      '1': 'tools',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Tool',
      '10': 'tools'
    },
  ],
  '8': [
    {'1': '_system_instruction'},
  ],
  '9': [
    {'1': 3, '2': 4},
    {'1': 4, '2': 5},
    {'1': 6, '2': 7},
    {'1': 7, '2': 8},
    {'1': 9, '2': 10},
    {'1': 10, '2': 11},
  ],
};

/// Descriptor for `GenerateContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateContentRequestDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZUNvbnRlbnRSZXF1ZXN0EhQKBW1vZGVsGAEgASgJUgVtb2RlbBJaChJzeXN0ZW'
    '1faW5zdHJ1Y3Rpb24YCCABKAsyJi5vZG1sLmdlbmFpX21vZHVsZXMuY29yZS5wcm90by5Db250'
    'ZW50SABSEXN5c3RlbUluc3RydWN0aW9uiAEBEkIKCGNvbnRlbnRzGAIgAygLMiYub2RtbC5nZW'
    '5haV9tb2R1bGVzLmNvcmUucHJvdG8uQ29udGVudFIIY29udGVudHMSOQoFdG9vbHMYBSADKAsy'
    'Iy5vZG1sLmdlbmFpX21vZHVsZXMuY29yZS5wcm90by5Ub29sUgV0b29sc0IVChNfc3lzdGVtX2'
    'luc3RydWN0aW9uSgQIAxAESgQIBBAFSgQIBhAHSgQIBxAISgQICRAKSgQIChAL');

@$core.Deprecated('Use generateContentResponseDescriptor instead')
const GenerateContentResponse$json = {
  '1': 'GenerateContentResponse',
  '2': [
    {
      '1': 'candidates',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Candidate',
      '10': 'candidates'
    },
  ],
  '9': [
    {'1': 2, '2': 3},
    {'1': 3, '2': 4},
    {'1': 4, '2': 5},
  ],
};

/// Descriptor for `GenerateContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateContentResponseDescriptor = $convert.base64Decode(
    'ChdHZW5lcmF0ZUNvbnRlbnRSZXNwb25zZRJICgpjYW5kaWRhdGVzGAEgAygLMigub2RtbC5nZW'
    '5haV9tb2R1bGVzLmNvcmUucHJvdG8uQ2FuZGlkYXRlUgpjYW5kaWRhdGVzSgQIAhADSgQIAxAE'
    'SgQIBBAF');

@$core.Deprecated('Use candidateDescriptor instead')
const Candidate$json = {
  '1': 'Candidate',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Content',
      '10': 'content'
    },
  ],
  '9': [
    {'1': 2, '2': 3},
    {'1': 3, '2': 4},
    {'1': 4, '2': 5},
    {'1': 5, '2': 6},
    {'1': 6, '2': 7},
    {'1': 7, '2': 8},
    {'1': 8, '2': 9},
    {'1': 9, '2': 10},
    {'1': 10, '2': 11},
    {'1': 11, '2': 12},
  ],
};

/// Descriptor for `Candidate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List candidateDescriptor = $convert.base64Decode(
    'CglDYW5kaWRhdGUSQAoHY29udGVudBgBIAEoCzImLm9kbWwuZ2VuYWlfbW9kdWxlcy5jb3JlLn'
    'Byb3RvLkNvbnRlbnRSB2NvbnRlbnRKBAgCEANKBAgDEARKBAgEEAVKBAgFEAZKBAgGEAdKBAgH'
    'EAhKBAgIEAlKBAgJEApKBAgKEAtKBAgLEAw=');
