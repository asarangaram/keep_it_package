import 'package:flutter/material.dart';

@immutable
class CLFormFieldDescriptors {
  const CLFormFieldDescriptors({required this.title, required this.label});
  final String title;
  final String label;
}

@immutable
class CLFormTextFieldDescriptor extends CLFormFieldDescriptors {
  const CLFormTextFieldDescriptor({
    required super.title,
    required super.label,
    this.hint,
    required this.initialValue,
    required this.onValidate,
    this.maxLines = 1,
  });
  final String? Function(String?) onValidate;
  final String? hint;
  final String initialValue;
  final int maxLines;
  @override
  String toString() {
    return "initialValues: $initialValue, title: $title, lable: $label}";
  }
}

@immutable
class CLFormSelectMultipleDescriptors<T> extends CLFormFieldDescriptors {
  const CLFormSelectMultipleDescriptors({
    required super.title,
    required super.label,
    required this.suggestionsAvailable,
    required this.initialValues,
    required this.labelBuilder,
    required this.descriptionBuilder,
    required this.onSelectSuggestion,
    required this.onCreateByLabel,
    required this.onValidate,
  });

  final List<T> suggestionsAvailable;
  final List<T> initialValues;
  final String Function(T e) labelBuilder;
  final String? Function(T e)? descriptionBuilder;
  final Future<T?> Function(T item) onSelectSuggestion;
  final Future<T?> Function(String label) onCreateByLabel;
  final String? Function(List<T>?)? onValidate;

  @override
  String toString() {
    return "initialValues: $initialValues, suggestionsAvailable: ${suggestionsAvailable.length}";
  }
}

@immutable
class CLFormSelectSingleDescriptors<T> extends CLFormFieldDescriptors {
  const CLFormSelectSingleDescriptors({
    required super.title,
    required super.label,
    required this.suggestionsAvailable,
    this.initialValues,
    required this.labelBuilder,
    required this.descriptionBuilder,
    required this.onSelectSuggestion,
    required this.onCreateByLabel,
    required this.onValidate,
  });

  final List<T> suggestionsAvailable;
  final T? initialValues;
  final String Function(T e) labelBuilder;
  final String? Function(T e)? descriptionBuilder;
  final Future<T?> Function(T item) onSelectSuggestion;
  final Future<T?> Function(String label) onCreateByLabel;
  final String? Function(T?)? onValidate;

  @override
  String toString() {
    return "initialValues: $initialValues, suggestionsAvailable: ${suggestionsAvailable.length}";
  }
}
