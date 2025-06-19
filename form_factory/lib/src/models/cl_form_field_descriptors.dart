import 'package:flutter/material.dart';
import 'package:form_factory/src/models/cl_form_field_state.dart';

@immutable
abstract class CLFormFieldDescriptors {
  const CLFormFieldDescriptors({required this.title, required this.label});
  final String title;
  final String label;

  CLFormFieldState createState({void Function()? listener});
  void disposeState(CLFormFieldState state);
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

  @override
  CLFormFieldState createState({void Function()? listener}) {
    return CLFormTextFieldState(this,
        controller: TextEditingController(),
        focusNode: FocusNode()..requestFocus());
  }

  @override
  void disposeState(CLFormFieldState state) {
    if (state is CLFormTextFieldState) {
      state
        ..controller.dispose()
        ..focusNode?.dispose();
    }
  }
}

@immutable
class CLFormSelectMultipleDescriptors extends CLFormFieldDescriptors {
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

  final List<Object> suggestionsAvailable;
  final List<Object> initialValues;
  final String Function(Object e) labelBuilder;
  final String? Function(Object e)? descriptionBuilder;
  final Future<Object?> Function(Object item) onSelectSuggestion;
  final Future<Object?> Function(String label) onCreateByLabel;
  final String? Function(List<Object>?)? onValidate;

  @override
  String toString() {
    return "initialValues: $initialValues, suggestionsAvailable: ${suggestionsAvailable.length}";
  }

  @override
  CLFormFieldState createState({void Function()? listener}) {
    return CLFormSelectMultipleState(
      this,
      scrollController: ScrollController(),
      wrapKey: GlobalKey(),
      searchController: SearchController(),
      selectedEntities: initialValues,
    );
  }

  @override
  void disposeState(CLFormFieldState state) {
    if (state is CLFormSelectMultipleState) {
      state
        ..scrollController.dispose()
        ..searchController.dispose();
    }
  }
}

@immutable
class CLFormSelectSingleDescriptors extends CLFormFieldDescriptors {
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

  final List<Object> suggestionsAvailable;
  final Object? initialValues;
  final String Function(Object e) labelBuilder;
  final String? Function(Object e)? descriptionBuilder;
  final Future<Object?> Function(Object item) onSelectSuggestion;
  final Object Function(String label) onCreateByLabel;
  final String? Function(Object?)? onValidate;

  @override
  String toString() {
    return "initialValues: $initialValues, suggestionsAvailable: ${suggestionsAvailable.length}";
  }

  @override
  CLFormFieldState createState({void Function()? listener}) {
    final searchController = SearchController();
    if (initialValues != null) {
      searchController.text = labelBuilder(initialValues!);
    }
    if (listener != null) {
      searchController.addListener(listener);
    }
    final state0 = CLFormSelectSingleState(this,
        searchController: searchController,
        selectedEntitry: [initialValues],
        searchControllerListener: listener);

    return state0;
  }

  @override
  void disposeState(CLFormFieldState state) {
    if (state is CLFormSelectSingleState) {
      if (state.searchControllerListener != null) {
        state.searchController.removeListener(state.searchControllerListener!);
      }
      state.searchController.dispose();
    }
  }
}
