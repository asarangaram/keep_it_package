import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/theme.dart';

class ThemeNotifier extends StateNotifier<KeepItTheme> {
  ThemeNotifier({required KeepItTheme theme}) : super(theme);
}

final themeProvider = StateNotifierProvider<ThemeNotifier, KeepItTheme>((ref) {
  return ThemeNotifier(
      theme: KeepItTheme(
          colorTheme: ColorTheme(
              textColor: Colors.black,
              buttonText: const Color.fromARGB(255, 0, 122, 255),
              backgroundColor: Colors.white.reduceBrightness(0.2),
              selectedColor: const Color.fromARGB(255, 0xFF, 0xFF, 0xF0)
                  .reduceBrightness(0.2),
              disabledColor: Colors.grey.shade300,
              overlayBackgroundColor: Colors.white,
              errorColor: Colors.red)));
});
