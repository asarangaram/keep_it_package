import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cl_form_field_descriptors.dart';
import '../models/cl_form_field_state.dart';
import '../style/cl_form_design.dart';

class CLFormTextField extends StatelessWidget {
  const CLFormTextField({
    required this.descriptors,
    required this.state,
    required this.onRefresh,
    this.actionBuilder,
    super.key,
  });

  final CLFormTextFieldDescriptor descriptors;
  final CLFormTextFieldState state;
  final void Function() onRefresh;
  final Widget Function(BuildContext context)? actionBuilder;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: true,
      showCursor: true,
      inputFormatters: switch (descriptors.maxLines > 1) {
        false => [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
        true => null
      },
      decoration: FormDesign.inputDecoration(
        context,
        label: descriptors.label,
        actionBuilder: actionBuilder,
      ),
      controller: state.controller,
      focusNode: state.focusNode,
      maxLines: descriptors.maxLines,
      validator: descriptors.validator,
    );
  }
}
