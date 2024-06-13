import 'package:flutter/material.dart';

class NotesTextFieldDecoration {
  static InputDecoration inputDecoration(
    BuildContext context, {
    required String label,
    required Widget Function(BuildContext context)? actionBuilder,
    String? hintText,
  }) =>
      InputDecoration(
        // isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
        labelText: label,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 8,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 8,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          gapPadding: 8,
        ),
        hintText: hintText,
        suffixIcon: actionBuilder?.call(context),
      );
}
