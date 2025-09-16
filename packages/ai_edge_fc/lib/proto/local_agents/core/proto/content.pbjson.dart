// This is a generated file - do not edit.
//
// Generated from local_agents/core/proto/content.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use typeDescriptor instead')
const Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'TYPE_UNSPECIFIED', '2': 0},
    {'1': 'STRING', '2': 1},
    {'1': 'NUMBER', '2': 2},
    {'1': 'INTEGER', '2': 3},
    {'1': 'BOOLEAN', '2': 4},
    {'1': 'ARRAY', '2': 5},
    {'1': 'OBJECT', '2': 6},
    {'1': 'NULL', '2': 7},
  ],
};

/// Descriptor for `Type`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List typeDescriptor = $convert.base64Decode(
    'CgRUeXBlEhQKEFRZUEVfVU5TUEVDSUZJRUQQABIKCgZTVFJJTkcQARIKCgZOVU1CRVIQAhILCg'
    'dJTlRFR0VSEAMSCwoHQk9PTEVBThAEEgkKBUFSUkFZEAUSCgoGT0JKRUNUEAYSCAoETlVMTBAH');

@$core.Deprecated('Use contentDescriptor instead')
const Content$json = {
  '1': 'Content',
  '2': [
    {
      '1': 'parts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Part',
      '10': 'parts'
    },
    {'1': 'role', '3': 2, '4': 1, '5': 9, '10': 'role'},
  ],
};

/// Descriptor for `Content`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contentDescriptor = $convert.base64Decode(
    'CgdDb250ZW50EjkKBXBhcnRzGAEgAygLMiMub2RtbC5nZW5haV9tb2R1bGVzLmNvcmUucHJvdG'
    '8uUGFydFIFcGFydHMSEgoEcm9sZRgCIAEoCVIEcm9sZQ==');

@$core.Deprecated('Use partDescriptor instead')
const Part$json = {
  '1': 'Part',
  '2': [
    {'1': 'text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'text'},
    {
      '1': 'function_call',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.FunctionCall',
      '9': 0,
      '10': 'functionCall'
    },
    {
      '1': 'function_response',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.FunctionResponse',
      '9': 0,
      '10': 'functionResponse'
    },
  ],
  '8': [
    {'1': 'data'},
  ],
  '9': [
    {'1': 3, '2': 4},
    {'1': 6, '2': 7},
    {'1': 7, '2': 8},
    {'1': 8, '2': 9},
    {'1': 9, '2': 10},
    {'1': 10, '2': 11},
    {'1': 11, '2': 12},
  ],
};

/// Descriptor for `Part`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List partDescriptor = $convert.base64Decode(
    'CgRQYXJ0EhQKBHRleHQYAiABKAlIAFIEdGV4dBJSCg1mdW5jdGlvbl9jYWxsGAQgASgLMisub2'
    'RtbC5nZW5haV9tb2R1bGVzLmNvcmUucHJvdG8uRnVuY3Rpb25DYWxsSABSDGZ1bmN0aW9uQ2Fs'
    'bBJeChFmdW5jdGlvbl9yZXNwb25zZRgFIAEoCzIvLm9kbWwuZ2VuYWlfbW9kdWxlcy5jb3JlLn'
    'Byb3RvLkZ1bmN0aW9uUmVzcG9uc2VIAFIQZnVuY3Rpb25SZXNwb25zZUIGCgRkYXRhSgQIAxAE'
    'SgQIBhAHSgQIBxAISgQICBAJSgQICRAKSgQIChALSgQICxAM');

@$core.Deprecated('Use toolDescriptor instead')
const Tool$json = {
  '1': 'Tool',
  '2': [
    {
      '1': 'function_declarations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.FunctionDeclaration',
      '10': 'functionDeclarations'
    },
  ],
  '9': [
    {'1': 2, '2': 3},
    {'1': 3, '2': 4},
    {'1': 4, '2': 5},
    {'1': 5, '2': 6},
  ],
};

/// Descriptor for `Tool`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toolDescriptor = $convert.base64Decode(
    'CgRUb29sEmcKFWZ1bmN0aW9uX2RlY2xhcmF0aW9ucxgBIAMoCzIyLm9kbWwuZ2VuYWlfbW9kdW'
    'xlcy5jb3JlLnByb3RvLkZ1bmN0aW9uRGVjbGFyYXRpb25SFGZ1bmN0aW9uRGVjbGFyYXRpb25z'
    'SgQIAhADSgQIAxAESgQIBBAFSgQIBRAG');

@$core.Deprecated('Use functionDeclarationDescriptor instead')
const FunctionDeclaration$json = {
  '1': 'FunctionDeclaration',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'parameters',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Schema',
      '9': 0,
      '10': 'parameters',
      '17': true
    },
    {
      '1': 'response',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Schema',
      '9': 1,
      '10': 'response',
      '17': true
    },
  ],
  '8': [
    {'1': '_parameters'},
    {'1': '_response'},
  ],
  '9': [
    {'1': 5, '2': 6},
  ],
};

/// Descriptor for `FunctionDeclaration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List functionDeclarationDescriptor = $convert.base64Decode(
    'ChNGdW5jdGlvbkRlY2xhcmF0aW9uEhIKBG5hbWUYASABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb2'
    '4YAiABKAlSC2Rlc2NyaXB0aW9uEkoKCnBhcmFtZXRlcnMYAyABKAsyJS5vZG1sLmdlbmFpX21v'
    'ZHVsZXMuY29yZS5wcm90by5TY2hlbWFIAFIKcGFyYW1ldGVyc4gBARJGCghyZXNwb25zZRgEIA'
    'EoCzIlLm9kbWwuZ2VuYWlfbW9kdWxlcy5jb3JlLnByb3RvLlNjaGVtYUgBUghyZXNwb25zZYgB'
    'AUINCgtfcGFyYW1ldGVyc0ILCglfcmVzcG9uc2VKBAgFEAY=');

@$core.Deprecated('Use functionCallDescriptor instead')
const FunctionCall$json = {
  '1': 'FunctionCall',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'args',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '9': 0,
      '10': 'args',
      '17': true
    },
  ],
  '8': [
    {'1': '_args'},
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
};

/// Descriptor for `FunctionCall`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List functionCallDescriptor = $convert.base64Decode(
    'CgxGdW5jdGlvbkNhbGwSEgoEbmFtZRgBIAEoCVIEbmFtZRIwCgRhcmdzGAIgASgLMhcuZ29vZ2'
    'xlLnByb3RvYnVmLlN0cnVjdEgAUgRhcmdziAEBQgcKBV9hcmdzSgQIAxAE');

@$core.Deprecated('Use functionResponseDescriptor instead')
const FunctionResponse$json = {
  '1': 'FunctionResponse',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'response',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'response'
    },
  ],
  '9': [
    {'1': 3, '2': 4},
    {'1': 4, '2': 5},
    {'1': 5, '2': 6},
  ],
};

/// Descriptor for `FunctionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List functionResponseDescriptor = $convert.base64Decode(
    'ChBGdW5jdGlvblJlc3BvbnNlEhIKBG5hbWUYASABKAlSBG5hbWUSMwoIcmVzcG9uc2UYAiABKA'
    'syFy5nb29nbGUucHJvdG9idWYuU3RydWN0UghyZXNwb25zZUoECAMQBEoECAQQBUoECAUQBg==');

@$core.Deprecated('Use schemaDescriptor instead')
const Schema$json = {
  '1': 'Schema',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.odml.genai_modules.core.proto.Type',
      '10': 'type'
    },
    {'1': 'format', '3': 2, '4': 1, '5': 9, '10': 'format'},
    {'1': 'title', '3': 24, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'nullable', '3': 4, '4': 1, '5': 8, '10': 'nullable'},
    {'1': 'enum', '3': 5, '4': 3, '5': 9, '10': 'enum'},
    {
      '1': 'items',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Schema',
      '9': 0,
      '10': 'items',
      '17': true
    },
    {'1': 'max_items', '3': 21, '4': 1, '5': 3, '10': 'maxItems'},
    {'1': 'min_items', '3': 22, '4': 1, '5': 3, '10': 'minItems'},
    {
      '1': 'properties',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Schema.PropertiesEntry',
      '10': 'properties'
    },
    {'1': 'required', '3': 8, '4': 3, '5': 9, '10': 'required'},
    {
      '1': 'minimum',
      '3': 11,
      '4': 1,
      '5': 1,
      '9': 1,
      '10': 'minimum',
      '17': true
    },
    {
      '1': 'maximum',
      '3': 12,
      '4': 1,
      '5': 1,
      '9': 2,
      '10': 'maximum',
      '17': true
    },
    {
      '1': 'any_of',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Schema',
      '10': 'anyOf'
    },
    {
      '1': 'property_ordering',
      '3': 23,
      '4': 3,
      '5': 9,
      '10': 'propertyOrdering'
    },
  ],
  '3': [Schema_PropertiesEntry$json],
  '8': [
    {'1': '_items'},
    {'1': '_minimum'},
    {'1': '_maximum'},
  ],
  '9': [
    {'1': 9, '2': 10},
    {'1': 10, '2': 11},
    {'1': 13, '2': 14},
    {'1': 14, '2': 15},
    {'1': 15, '2': 16},
    {'1': 16, '2': 17},
    {'1': 17, '2': 18},
    {'1': 19, '2': 20},
    {'1': 20, '2': 21},
  ],
};

@$core.Deprecated('Use schemaDescriptor instead')
const Schema_PropertiesEntry$json = {
  '1': 'PropertiesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.odml.genai_modules.core.proto.Schema',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Schema`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List schemaDescriptor = $convert.base64Decode(
    'CgZTY2hlbWESNwoEdHlwZRgBIAEoDjIjLm9kbWwuZ2VuYWlfbW9kdWxlcy5jb3JlLnByb3RvLl'
    'R5cGVSBHR5cGUSFgoGZm9ybWF0GAIgASgJUgZmb3JtYXQSFAoFdGl0bGUYGCABKAlSBXRpdGxl'
    'EiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIaCghudWxsYWJsZRgEIAEoCFIIbn'
    'VsbGFibGUSEgoEZW51bRgFIAMoCVIEZW51bRJACgVpdGVtcxgGIAEoCzIlLm9kbWwuZ2VuYWlf'
    'bW9kdWxlcy5jb3JlLnByb3RvLlNjaGVtYUgAUgVpdGVtc4gBARIbCgltYXhfaXRlbXMYFSABKA'
    'NSCG1heEl0ZW1zEhsKCW1pbl9pdGVtcxgWIAEoA1IIbWluSXRlbXMSVQoKcHJvcGVydGllcxgH'
    'IAMoCzI1Lm9kbWwuZ2VuYWlfbW9kdWxlcy5jb3JlLnByb3RvLlNjaGVtYS5Qcm9wZXJ0aWVzRW'
    '50cnlSCnByb3BlcnRpZXMSGgoIcmVxdWlyZWQYCCADKAlSCHJlcXVpcmVkEh0KB21pbmltdW0Y'
    'CyABKAFIAVIHbWluaW11bYgBARIdCgdtYXhpbXVtGAwgASgBSAJSB21heGltdW2IAQESPAoGYW'
    '55X29mGBIgAygLMiUub2RtbC5nZW5haV9tb2R1bGVzLmNvcmUucHJvdG8uU2NoZW1hUgVhbnlP'
    'ZhIrChFwcm9wZXJ0eV9vcmRlcmluZxgXIAMoCVIQcHJvcGVydHlPcmRlcmluZxpkCg9Qcm9wZX'
    'J0aWVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSOwoFdmFsdWUYAiABKAsyJS5vZG1sLmdlbmFp'
    'X21vZHVsZXMuY29yZS5wcm90by5TY2hlbWFSBXZhbHVlOgI4AUIICgZfaXRlbXNCCgoIX21pbm'
    'ltdW1CCgoIX21heGltdW1KBAgJEApKBAgKEAtKBAgNEA5KBAgOEA9KBAgPEBBKBAgQEBFKBAgR'
    'EBJKBAgTEBRKBAgUEBU=');
