import 'package:flutter/material.dart';

class FormDesign {
  static InputDecoration inputDecoration(BuildContext context,
          {required String label, BorderRadius? borderRadius}) =>
      InputDecoration(
        enabled: true,
        contentPadding:
            const EdgeInsets.only(left: 32, bottom: 8, top: 8, right: 32),
        labelText: label,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Colors.blueGrey),
          borderRadius: borderRadius ?? BorderRadius.zero,
          gapPadding: 8,
        ),
      );
}
