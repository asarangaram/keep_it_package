import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cl_scale_type.dart';

class CLTextField extends StatelessWidget {
  const CLTextField(
    this.controller, {
    super.key,
    this.label,
    this.hint,
    this.focusNode,
    this.suffix,
    this.prefix,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  })  : validator = null,
        multiLine = false,
        maxLines = 1;

  const CLTextField.multiLine(
    this.controller, {
    super.key,
    this.label,
    this.hint,
    this.focusNode,
    this.suffix,
    this.prefix,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 3,
    this.keyboardType = TextInputType.multiline,
    this.enabled = true,
  })  : validator = null,
        multiLine = true,
        textInputAction = TextInputAction.newline;

  const CLTextField.form(
    this.controller, {
    required String? Function(String?) validator,
    super.key,
    this.label,
    this.hint,
    this.focusNode,
    this.suffix,
    this.prefix,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  })  
  // ignore: prefer_initializing_formals
  : validator = validator,
        multiLine = false,
        maxLines = 1;

  const CLTextField.multiLineForm(
    this.controller, {
    required String? Function(String?) validator,
    super.key,
    this.label,
    this.hint,
    this.focusNode,
    this.suffix,
    this.prefix,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 3,
    this.keyboardType = TextInputType.multiline,
    this.enabled = true,
    // ignore: prefer_initializing_formals
  })  : validator = validator,
        multiLine = true,
        textInputAction = TextInputAction.newline;
  final TextEditingController controller;

  //InputDecoration
  final String? label;
  final String? hint;
  final Widget? suffix;
  final Widget? prefix;

  final TextInputAction textInputAction;
  final TextInputType keyboardType;

  final void Function(String val)? onChanged;
  final void Function(String)? onFieldSubmitted;

  final FocusNode? focusNode;
  final bool enabled;

  // Internally Managed
  final bool multiLine;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        enabled: enabled,
        showCursor: true,
        inputFormatters: switch (multiLine) {
          false => [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
          true => null
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? label,
          suffix: suffix,
          prefix: prefix,
        ),
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  static OutlineInputBorder buildOutlineInputBorder(
    BuildContext context, {
    double width = 1,
  }) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          width: width,
        ),
      );

  static TextStyle buildTextStyle(
    BuildContext context,
  ) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: CLScaleType.standard.fontSize,
          );
}
