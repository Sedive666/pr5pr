import 'package:flutter/material.dart';

import '../models/validators.dart';

class FormValues {
  final Map<String, String> text = {};
  final Map<String, int?> choice = {};
  final Map<String, String?> textChoice = {};
  final Map<String, List<int>> multi = {};

  String str(String key) => (text[key] ?? '').trim();
  int number(String key, [int fallback = 0]) =>
      int.tryParse(str(key)) ?? fallback;
  int? pick(String key) => choice[key];
  String? option(String key) => textChoice[key];
  List<int> list(String key) => multi[key] ?? const [];
}

sealed class FieldSpec {
  const FieldSpec({required this.name, required this.label, this.hint});

  final String name;
  final String label;
  final String? hint;
}

class TextFieldSpec extends FieldSpec {
  const TextFieldSpec({
    required super.name,
    required super.label,
    super.hint,
    this.validator,
    this.multiline = false,
    this.numeric = false,
  });

  final Validator? validator;
  final bool multiline;
  final bool numeric;
}

class DropdownFieldSpec extends FieldSpec {
  const DropdownFieldSpec({
    required super.name,
    required super.label,
    required this.options,
    this.validator,
    this.dependsOn,
    this.filter,
  });

  final List<DropdownEntry> Function(FormValues values) options;
  final String? Function(int? value)? validator;
  final String? dependsOn;
  final bool Function(FormValues values, DropdownEntry entry)? filter;
}

class TextDropdownFieldSpec extends FieldSpec {
  const TextDropdownFieldSpec({
    required super.name,
    required super.label,
    required this.options,
    this.validator,
  });

  final List<String> options;
  final String? Function(String? value)? validator;
}

class MultiSelectFieldSpec extends FieldSpec {
  const MultiSelectFieldSpec({
    required super.name,
    required super.label,
    super.hint,
    required this.options,
    this.validator,
    this.dependsOn,
    this.filter,
  });

  final List<DropdownEntry> Function(FormValues values) options;
  final String? Function(List<int> value)? validator;
  final String? dependsOn;
  final bool Function(FormValues values, DropdownEntry entry)? filter;
}

class SectionSpec extends FieldSpec {
  const SectionSpec({
    required super.name,
    required super.label,
    required this.fields,
    this.optional = false,
    this.enabledLabel,
  });

  final List<FieldSpec> fields;
  final bool optional;
  final String? enabledLabel;
}

class DropdownEntry {
  const DropdownEntry(this.id, this.label, {this.group});

  final int id;
  final String label;
  final int? group;
}

List<DropdownEntry> entriesOf<T>(
  List<T> items,
  int Function(T) id,
  String Function(T) label, {
  int? Function(T)? group,
}) => [
  for (final item in items)
    DropdownEntry(id(item), label(item), group: group?.call(item)),
];

InputDecoration fieldDecoration(String label, {String? error, String? hint}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      border: const OutlineInputBorder(),
    );
