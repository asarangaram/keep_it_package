// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui' as ui;
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'package:video_thumbnail/video_thumbnail.dart';
import '../utils/file_handler.dart';

class ImageNotifier extends StateNotifier<AsyncValue<ui.Image>> {
  MapEntry<String, CLMediaType> mediaEntry;
  ImageNotifier(this.mediaEntry) : super(const AsyncValue.loading()) {
    _get();
  }

  Future<void> _get() async {
    state = await AsyncValue.guard(() async {
      final String absPath = await getAbsoluteFilePath(mediaEntry.key);
      try {
        return switch (mediaEntry.value) {
          CLMediaType.image => await tryAsImage(absPath),
          CLMediaType.video => await tryAsVideo(absPath),
          _ => throw UnimplementedError()
        };
      } catch (err) {
        throw Exception(
            "Failed to load the media ${mediaEntry.key}, ${mediaEntry.value}");
      }
    });
  }

  Future<ui.Image> tryAsVideo(String mediaPath) async =>
      await loadImage((await VideoThumbnail.thumbnailData(
        video: await getAbsoluteFilePath(mediaPath),
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            256, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      ))!);

  Future<String> getAbsoluteFilePath(String mediaPath) async {
    return switch (mediaPath) {
      (String s) when mediaPath.startsWith('/') => s,
      (String s) when mediaPath.startsWith('assets') => s,
      _ => path.join(await FileHandler.getDocumentsDirectory(null), mediaPath),
    };
  }

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
    AsyncValue<ui.Image>, MapEntry<String, CLMediaType>>((ref, mediaEntry) {
  return ImageNotifier(mediaEntry);
});
