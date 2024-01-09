// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui' as ui;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'package:video_thumbnail/video_thumbnail.dart';

class VideoHandler {
  static Future<Uint8List> createVideoThumbnail(String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          64, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return thumbnail!;
  }

  static Future<void> generateVideoThumbnail(String videoPath) async {
    File thumbnailFile = File("$videoPath.tb");
    final thumbnail = await createVideoThumbnail(videoPath);
    await thumbnailFile.writeAsBytes(thumbnail);
  }

  static Future<Uint8List> loadVideoThumbnail(String videoPath,
      {bool regenerateIfNotExists = false, bool regenerate = false}) async {
    File thumbnailFile = File("$videoPath.tb");
    if (!regenerate) {
      if (thumbnailFile.existsSync()) {
        return await thumbnailFile.readAsBytes();
      }
    }
    final thumbnail = await createVideoThumbnail(videoPath);
    if (regenerateIfNotExists || regenerate) {
      await thumbnailFile.writeAsBytes(thumbnail);
    }
    return thumbnail;
  }
}

class ImageNotifier extends StateNotifier<AsyncValue<ui.Image>> {
  CLMediaInfo mediaInfo;
  ImageNotifier(this.mediaInfo) : super(const AsyncValue.loading()) {
    _get();
  }

  Future<void> _get() async {
    state = await AsyncValue.guard(() async {
      final String absPath =
          await FileHandler.getAbsoluteFilePath(mediaInfo.path);
      try {
        return switch (mediaInfo.type) {
          CLMediaType.image => await tryAsImage(absPath),
          CLMediaType.video => await tryAsVideo(absPath),
          _ => throw UnimplementedError()
        };
      } catch (err) {
        throw Exception(
            "Failed to load the media ${mediaInfo.path}, ${mediaInfo.type}");
      }
    });
  }

  Future<ui.Image> tryAsVideo(String mediaPath) async =>
      await loadImage(await VideoHandler.loadVideoThumbnail(
          await FileHandler.getAbsoluteFilePath(mediaPath),
          regenerateIfNotExists: true));

  Future<ui.Image> tryAsImage(String mediaPath) async =>
      await loadImage(switch (mediaPath) {
        (String s) when mediaPath.startsWith('/') =>
          (await rootBundle.load(s)).buffer.asUint8List(),
        (String s) when mediaPath.startsWith('assets') =>
          Uint8List.fromList(await File(s).readAsBytes()),
        _ => await tryDocumentsDir(mediaPath),
      });

  Future<ui.Image> loadImage(Uint8List data) async {
    ui.Codec codec = await ui.instantiateImageCodec(data);
    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }

  Future<Uint8List> tryDocumentsDir(String imagePath) async {
    final documentsDir = await FileHandler.getDocumentsDirectory(null);
    File file = File(path.join(documentsDir, imagePath));
    if (!file.existsSync()) {
      throw Exception("File doesn't exists");
    }
    List<int> bytes = await file.readAsBytes();
    return Uint8List.fromList(bytes);
  }
}

final imageProvider = StateNotifierProvider.family<ImageNotifier,
    AsyncValue<ui.Image>, CLMediaInfo>((ref, mediaEntry) {
  return ImageNotifier(mediaEntry);
});
