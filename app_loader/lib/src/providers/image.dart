// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageNotifier extends StateNotifier<AsyncValue<ui.Image>> {
  String imagePath;
  ImageNotifier(this.imagePath) : super(const AsyncValue.loading()) {
    _get();
  }

  Future<void> _get() async {
    state = await AsyncValue.guard(() async {
      try {
        if (imagePath.startsWith('/')) {
          return await imageFromFile;
        }
        if (imagePath.startsWith('assets')) {
          return await imageFromAssets;
        }
        throw UnimplementedError();
      } catch (err) {
        throw Exception("Failed to load Image");
      }
    });
  }

  Future<ui.Image> get imageFromAssets async {
    final data = await rootBundle.load(imagePath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }

  Future<ui.Image> get imageFromFile async {
    File file = File(imagePath);
    List<int> bytes = await file.readAsBytes();

    // Decode the image from bytes
    ui.Codec codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    ui.FrameInfo fi = await codec.getNextFrame();

    ui.Image uiImage = fi.image;
    return uiImage;
  }
}

final imageProvider =
    StateNotifierProvider.family<ImageNotifier, AsyncValue<ui.Image>, String>(
        (ref, imagePath) {
  return ImageNotifier(imagePath);
});
