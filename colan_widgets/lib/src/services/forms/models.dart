import 'package:flutter/material.dart';

enum CLFormFieldTypes { textField, textFieldMultiLine, selector }

class CLFormField {
  CLFormField({
    required this.type,
  });
  CLFormFieldTypes type;
}

class CLFromFieldTypeText extends CLFormField {
  CLFromFieldTypeText({
    required super.type,
    required this.validator,
    required this.initialValue,
    this.label,
    this.hint,
  });
  String? Function(String?) validator;
  String? label;
  String? hint;
  String initialValue;
}

class CLFromFieldTypeSelector extends CLFormField {
  CLFromFieldTypeSelector({
    required super.type,
    required this.initialEntries,
    required this.getSuggestions,
    required this.hasMatchingSuggestion,
    required this.buildLabel,
    required this.onSelectSuggestion,
    required this.onCreate,
    this.buildDescription,
  });

  final List<Object>? initialEntries;
  final List<Object> Function(BuildContext context, String? searchtext)
      getSuggestions;
  final bool Function(BuildContext context, String? searchtext)
      hasMatchingSuggestion;
  final String Function(Object object) buildLabel;
  final String? Function(Object object)? buildDescription;
  final void Function(BuildContext context, Object object) onSelectSuggestion;
  final void Function(BuildContext context, String newLabel) onCreate;
}
