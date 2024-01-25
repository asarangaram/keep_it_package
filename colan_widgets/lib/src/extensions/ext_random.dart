import 'dart:math';

import 'package:flutter/material.dart';

/// Usage
/// final random = Random(42);
/// final randomColor = random.color;
///
extension ExtRandom on Random {
  Color get color => Colors.primaries[nextInt(Colors.primaries.length)];
}
