import 'package:flutter/material.dart';

@immutable
class CLDimension {
  const CLDimension({
    required this.width,
    required this.height,
  });
  final int width;
  final int height;

  @override
  bool operator ==(covariant CLDimension other) {
    if (identical(this, other)) return true;

    return other.width == width && other.height == height;
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode;

  @override
  String toString() => 'Dimension(width: $width, height: $height)';
}
