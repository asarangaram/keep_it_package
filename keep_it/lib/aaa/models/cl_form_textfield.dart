import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'cl_form_field_descriptors.dart';
import 'cl_form_field_state.dart';

class CLFormTextField extends StatelessWidget {
  const CLFormTextField({
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    super.key,
  });

  final CLFormTextFieldDescriptor descriptors;

  final CLFormTextFieldState state;

  final void Function() onRefresh;
  @override
  Widget build(BuildContext context) {
    return CLTextField.form(
      state.controller,
      validator: descriptors.validator,
      focusNode: state.focusNode,
      label: descriptors.label,
      hint: descriptors.hint,
    );
  }
}
