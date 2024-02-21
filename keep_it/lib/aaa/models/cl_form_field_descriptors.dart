import 'package:flutter/material.dart';

@immutable
class CLFormFieldDescriptors {
  const CLFormFieldDescriptors({required this.title, required this.label});
  final String title;
  final String label;
}

@immutable
class CLFormSelectDescriptors extends CLFormFieldDescriptors {
  const CLFormSelectDescriptors({
    required super.title,
    required super.label,
    required this.suggestionsAvailable,
    required this.initialValues,
    required this.labelBuilder,
    required this.descriptionBuilder,
    required this.onSelectSuggestion,
    required this.onCreateByLabel,
  });

  final List<Object> suggestionsAvailable;
  final List<Object> initialValues;
  final String Function(Object e) labelBuilder;
  final String? Function(Object e)? descriptionBuilder;
  final Future<Object?> Function(Object item) onSelectSuggestion;
  final Future<Object?> Function(String label) onCreateByLabel;
}
