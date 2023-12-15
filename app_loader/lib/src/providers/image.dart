// ignore_for_file: public_member_api_docs, sort_constructors_first
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
        final data = await rootBundle.load(imagePath);
        ui.Codec codec =
            await ui.instantiateImageCodec(data.buffer.asUint8List());
        ui.FrameInfo fi = await codec.getNextFrame();
        ui.Image uiImage = fi.image;

        return uiImage;
      } catch (err) {
        throw Exception("Failed to load Image");
      }
    });
  }
}

final imageProvider =
    StateNotifierProvider.family<ImageNotifier, AsyncValue<ui.Image>, String>(
        (ref, imagePath) {
  return ImageNotifier(imagePath);
});
