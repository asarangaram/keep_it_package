// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../utils/file_handler.dart';

class MediaData {}

class ImageData extends MediaData {
  ui.Image image;

  ImageData(this.image);
}

class ImageNotifier extends StateNotifier<AsyncValue<ImageData>> {
  String imagePath;
  ImageNotifier(this.imagePath) : super(const AsyncValue.loading()) {
    _get();
  }

  Future<void> _get() async {
    state = await AsyncValue.guard(() async {
      final Uint8List data;
      try {
        data = switch (imagePath) {
          (String s) when imagePath.startsWith('/') =>
            (await rootBundle.load(s)).buffer.asUint8List(),
          (String s) when imagePath.startsWith('assets') =>
            Uint8List.fromList(await File(s).readAsBytes()),
          _ => await tryDocumentsDir(imagePath)
        };
      } catch (err) {
        throw Exception("Failed to load Image");
      }
      return await loadImage(data);
    });
  }

  Future<ImageData> loadImage(Uint8List data) async {
    ui.Codec codec = await ui.instantiateImageCodec(data);
    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return ImageData(uiImage);
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

final imageProvider =
    StateNotifierProvider.family<ImageNotifier, AsyncValue<ImageData>, String>(
        (ref, imagePath) {
  return ImageNotifier(imagePath);
});
