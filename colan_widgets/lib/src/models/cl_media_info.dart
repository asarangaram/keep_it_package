import 'dart:ui' as ui;

import 'cl_media_type.dart';

sealed class CLMedia {
  final String path;
  final CLMediaType type;
  ui.Image? preview;
  late double aspectRatio;

  CLMedia({
    required this.path,
    required this.type,
    this.preview,
  }) {
    if (!path.startsWith('/')) {
      throw Exception("CLMedia must have absolute path");
    }
    if (preview == null) {
      aspectRatio = 1;
    } else {
      aspectRatio = preview!.width / preview!.height;
    }
  }

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
    return "$path, $type, $aspectRatio ${(preview != null) ? "${preview?.width} x ${preview?.height}" : ""}";
  }
}

class CLMediaImage extends CLMedia {
  ui.Image? data;
  CLMediaImage({
    required super.path,
    required super.type,
    super.preview,
    this.data,
  }) : super();

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
        preview: preview ?? super.preview);
  }

  static Future<ui.Image> createThumbnail(
      ui.Image originalImage, int thumbnailWidth, int thumbnailHeight) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(
        recorder,
        ui.Rect.fromPoints(const ui.Offset(0.0, 0.0),
            ui.Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble())));
    canvas.drawImageRect(
        originalImage,
        ui.Rect.fromPoints(
            const ui.Offset(0.0, 0.0),
            ui.Offset(originalImage.width.toDouble(),
                originalImage.height.toDouble())),
        ui.Rect.fromPoints(const ui.Offset(0.0, 0.0),
            ui.Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble())),
        ui.Paint());

    final ui.Picture picture = recorder.endRecording();
    final ui.Image thumbnailImage =
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
        preview: preview ?? super.preview);
  }
}

class CLMediaInfoGroup {
  final List<CLMedia> list;
  CLMediaInfoGroup(this.list);

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;
}
