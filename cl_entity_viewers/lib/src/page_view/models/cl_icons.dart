import 'package:flutter/material.dart';

@immutable
class PlayerUIPreferences {
  final foregroundColor = const Color.fromARGB(192, 0xFF, 0xFF, 0xFF);

  final inactiveColor = const Color.fromARGB(192, 64, 64, 64);
  final activeBufferColor = const Color.fromARGB(192, 128, 128, 128);
}

PlayerUIPreferences playerUIPreferences = PlayerUIPreferences();
