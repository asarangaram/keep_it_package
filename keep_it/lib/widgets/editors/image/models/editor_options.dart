// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';

import 'aspect_ratio.dart' as aratio;

@immutable
class EditorOptions {
  const EditorOptions({
    this.controller,
    this.aspectRatio = const aratio.AspectRatio(title: 'unspecified'),
    this.rotation = 0,
  });

  final aratio.AspectRatio aspectRatio;
  final int rotation;
  final GlobalKey<ExtendedImageEditorState>? controller;

  List<aratio.AspectRatio> get availableAspectRatio => const [
        aratio.AspectRatio(title: 'Freeform'),
        aratio.AspectRatio(title: '1:1', ratio: 1),
        aratio.AspectRatio(title: '4:3', ratio: 4 / 3),
        aratio.AspectRatio(title: '5:4', ratio: 5 / 4),
        aratio.AspectRatio(title: '7:5', ratio: 7 / 5),
        aratio.AspectRatio(title: '16:9', ratio: 16 / 9),
      ];

  EditorOptions copyWith({
    aratio.AspectRatio? aspectRatio,
    int? rotation,
    GlobalKey<ExtendedImageEditorState>? controller,
  }) {
    return EditorOptions(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      rotation: rotation ?? this.rotation,
      controller: controller ?? this.controller,
    );
  }

  @override
  String toString() =>
      'EditorOptions(aspectRatio: $aspectRatio, rotation: $rotation)';

  @override
  bool operator ==(covariant EditorOptions other) {
    if (identical(this, other)) return true;

    return other.aspectRatio == aspectRatio && other.rotation == rotation;
  }

  @override
  int get hashCode =>
      aspectRatio.hashCode ^ rotation.hashCode ^ controller.hashCode;

  bool get hasData {
    return !(this == const EditorOptions());
  }
}
