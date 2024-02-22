import 'package:flutter/material.dart';

class FormDesign {
  static InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          gapPadding: 0,
        ),
      );
}