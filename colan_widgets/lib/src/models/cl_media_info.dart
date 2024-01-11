import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'cl_media_type.dart';

@immutable
sealed class CLMedia {
  CLMedia({
    required this.path,
    required this.type,
    this.preview,
  }) {
    if (!path.startsWith('/')) {
      throw Exception('CLMedia must have absolute path');
    }
    if (preview == null) {
      aspectRatio = 1;
    } else {
      aspectRatio = preview!.width / preview!.height;
    }
  }
  final String path;
  final CLMediaType type;
  final ui.Image? preview;
  late final double aspectRatio;

  CLMedia copyWith({
    String? path,
    CLMediaType? type,
    ui.Image? preview,
  });

  // Match only path and type, nothing else matters.

  @override
  bool operator ==(covariant CLMediaImage other) {
    if (identical(this, other)) return true;

    return other.path == path && other.type == type;
  }

  @override
  int get hashCode => path.hashCode ^ type.hashCode;

  @override
  String toString() {
    return '$path, $type, $aspectRatio '
        ' ${(preview != null) ? "${preview?.width} x ${preview?.height}" : ""}';
  }
}

@immutable
class CLMediaImage extends CLMedia {
  CLMediaImage({
    required super.path,
    required super.type,
    super.preview,
    this.data,
  }) : super();
  final ui.Image? data;

  @override
  CLMediaImage copyWith({
    String? path,
    CLMediaType? type,
    ui.Image? preview,
    ui.Image? data,
  }) {
    return CLMediaImage(
      data: data ?? this.data,
      path: path ?? super.path,
      type: type ?? super.type,
      preview: preview ?? super.preview,
    );
  }

  static Future<ui.Image> createThumbnail(
    ui.Image originalImage,
    int thumbnailWidth,
    int thumbnailHeight,
  ) async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
      ui.Rect.fromPoints(
        ui.Offset.zero,
        ui.Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble()),
      ),
    ).drawImageRect(
      originalImage,
      ui.Rect.fromPoints(
        ui.Offset.zero,
        ui.Offset(
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
      ),
      ui.Rect.fromPoints(
        ui.Offset.zero,
        ui.Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble()),
      ),
      ui.Paint(),
    );

    final picture = recorder.endRecording();
    final thumbnailImage =
        await picture.toImage(thumbnailWidth, thumbnailHeight);
    return thumbnailImage;
  }
}

class CLMediaVideo extends CLMedia {
  CLMediaVideo({
    required super.path,
    required super.type,
    super.preview,
  }) : super();

  @override
  CLMediaImage copyWith({
    String? path,
    CLMediaType? type,
    ui.Image? preview,
  }) {
    return CLMediaImage(
      path: path ?? super.path,
      type: type ?? super.type,
      preview: preview ?? super.preview,
    );
  }
}

class CLMediaInfoGroup {
  CLMediaInfoGroup(this.list);
  final List<CLMedia> list;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;
}
