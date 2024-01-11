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
      maxWidth: 64, // specify the width of the thumbnail, let the height
      // auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    return thumbnail!;
  }

  static Future<void> generateVideoThumbnail(String videoPath) async {
    final thumbnailFile = File('$videoPath.tb');
    final thumbnail = await createVideoThumbnail(videoPath);
    await thumbnailFile.writeAsBytes(thumbnail);
  }

  static Future<Uint8List> loadVideoThumbnail(
    String videoPath, {
    bool regenerateIfNotExists = false,
    bool regenerate = false,
  }) async {
    final thumbnailFile = File('$videoPath.tb');
    if (!regenerate) {
      if (thumbnailFile.existsSync()) {
        return thumbnailFile.readAsBytes();
      }
    }
    final thumbnail = await createVideoThumbnail(videoPath);
    if (regenerateIfNotExists || regenerate) {
      await thumbnailFile.writeAsBytes(thumbnail);
    }
    return thumbnail;
  }
}

class MediaNotifier extends StateNotifier<AsyncValue<CLMedia>> {
  CLMedia mediaInfo;
  MediaNotifier(this.mediaInfo) : super(const AsyncValue.loading()) {
    _get();
  }

  Future<void> _get() async {
    state = await AsyncValue.guard(() async {
      try {
        final absPath = await FileHandler.getAbsoluteFilePath(mediaInfo.path);
        final media = mediaInfo.copyWith(path: absPath);

        final image = await loadImage(
          await switch (media.type) {
            CLMediaType.image => tryAsImage(absPath),
            CLMediaType.video => tryAsVideo(absPath),
            _ => throw UnimplementedError()
          },
        );

        return switch (media.type) {
          CLMediaType.image => CLMediaImage(
              path: absPath,
              type: media.type,
              preview: image,
              data: image,
            ),
          CLMediaType.video =>
            CLMediaVideo(path: absPath, type: media.type, preview: image),
          _ => throw UnimplementedError()
        };
      } catch (err) {
        throw Exception(
          'Failed to load the media ${mediaInfo.path}, ${mediaInfo.type}',
        );
      }
    });
  }

  Future<Uint8List> tryAsVideo(String mediaPath) async {
    return switch (mediaPath) {
      (final String s) when mediaPath.startsWith('/') =>
        await VideoHandler.loadVideoThumbnail(s, regenerateIfNotExists: true),
      (final String s) when mediaPath.startsWith('assets') =>
        throw Exception('Video from assets is not handled: $s'),
      _ => throw Exception('Relative Path not supported.'),
    };
  }

  Future<Uint8List> tryAsImage(String mediaPath) async => switch (mediaPath) {
        (final String s) when mediaPath.startsWith('/') =>
          Uint8List.fromList(await File(s).readAsBytes()),
        (final String s) when mediaPath.startsWith('assets') =>
          (await rootBundle.load(s)).buffer.asUint8List(),
        _ => throw Exception('Relative Path not supported.'),
      };

  Future<ui.Image> loadImage(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final fi = await codec.getNextFrame();
    final uiImage = fi.image;

    return uiImage;
  }

  Future<Uint8List> tryDocumentsDir(String imagePath) async {
    final documentsDir = await FileHandler.getDocumentsDirectory(null);
    final file = File(path.join(documentsDir, imagePath));
    if (!file.existsSync()) {
      throw Exception("File doesn't exists");
    }
    final List<int> bytes = await file.readAsBytes();
    return Uint8List.fromList(bytes);
  }
}

final mediaProvider =
    StateNotifierProvider.family<MediaNotifier, AsyncValue<CLMedia>, CLMedia>(
        (ref, mediaEntry) {
  return MediaNotifier(mediaEntry);
});
