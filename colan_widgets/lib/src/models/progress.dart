import 'package:flutter/material.dart';

@immutable
class Progress {
  const Progress({
    required double fractCompleted,
    required this.currentItem,
    this.isDone = false,
  }) : fractCompleted = fractCompleted > 1.0 ? 1.0 : fractCompleted;
  final double fractCompleted;
  final String currentItem;
  final bool isDone;

  @override
  String toString() =>
      'Progress(fractCompleted: ${fractCompleted.toStringAsFixed(2)}, currentItem: $currentItem, isDone: $isDone)';

  double get percentage => fractCompleted * 100;

  String get percentageAsText => percentage.toStringAsFixed(1);
}
