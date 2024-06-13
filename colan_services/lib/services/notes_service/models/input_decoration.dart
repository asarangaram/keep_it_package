import 'package:flutter/material.dart';

class NotesTextFieldDecoration {
  static InputDecoration inputDecoration(
    BuildContext context, {
    required Widget Function(BuildContext context)? actionBuilder,
    String? label,
    String? hintText,
    bool hasBorder = true,
  }) =>
      InputDecoration(
        // isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
        labelText: label,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        enabledBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                gapPadding: 8,
              )
            : InputBorder.none,
        focusedBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                gapPadding: 8,
              )
            : InputBorder.none,
        errorBorder: hasBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
                gapPadding: 8,
              )
            : InputBorder.none,
        hintText: hintText,
        suffixIcon: actionBuilder?.call(context),
      );
}
