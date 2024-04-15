import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:keep_it/widgets/editors/image/models/editor_options.dart';
import 'package:path_provider/path_provider.dart';

class ImageProcessing {
  /* static Future<Uint8List?> cropImageWithThread({
    required Uint8List imageBytes,
    required Rect rect,
  }) async {
    final cropTask = img.Command()
      ..decodeImage(imageBytes)
      ..copyCrop(
        x: rect.topLeft.dx.ceil(),
        y: rect.topLeft.dy.ceil(),
        height: rect.height.ceil(),
        width: rect.width.ceil(),
      );

    final encodeTask = img.Command()
      ..subCommand = cropTask
      ..encodeJpg();

    return encodeTask.getBytesThread();
  }

  static Future<String?> saveImageToCache(
    Uint8List imageBytes,
    EditorOptions editorOptions,
  ) async {
    try {
      final cacheDir = await getTemporaryDirectory();

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = '${cacheDir.path}/$fileName';

      await rotateAndSaveImage(imageBytes, imageFile, editorOptions);
      return imageFile;
    } catch (e) {
      /*** */
      return null;
    }
  }

  static Future<void> rotateAndSaveImage(
    Uint8List imageData,
    String filePath,
    EditorOptions editorOptions,
  ) async {
    // Decode the image
    final codec = await ui.instantiateImageCodec(imageData);
    final frameInfo = await codec.getNextFrame();
    final image = frameInfo.image;

    // Create a new image with rotated dimensions
    final newWidth = image.height;
    final newHeight = image.width;

    // Create a recorder for drawing the rotated image
    final recorder = ui.PictureRecorder();

    ui.Canvas(recorder)

      // Perform the rotation
      ..rotate((math.pi / 2) * editorOptions.rotation) // 90 degrees
      ..drawImage(image, ui.Offset.zero, ui.Paint());

    // Finish recording
    final rotatedPicture = recorder.endRecording();
    final rotatedImage = await rotatedPicture.toImage(newWidth, newHeight);

    // Convert the rotated image to PNG bytes
    final byteData =
        await rotatedImage.toByteData(format: ui.ImageByteFormat.png);
    final rotatedImageData = byteData!.buffer.asUint8List();

    // Save the rotated image to file
    await saveFile(rotatedImageData);
  } */

  static Future<String?> saveFile(img.Image? image) async {
    if (image == null) return null;
    final cacheDir = await getTemporaryDirectory();

    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageFile = '${cacheDir.path}/$fileName';

    await img.encodeJpgFile(imageFile, image);

    return imageFile;
  }

  static Future<String?> process({required EditorOptions editorOptions}) async {
    final state = editorOptions.controller?.currentState;
    if (state != null) {
      var image = img.decodeImage(state.rawImageData);
      if (image == null) return null;

      final rect = state.getCropRect();
      if (rect != null) {
        image = img.copyCrop(
          image,
          x: rect.left.toInt(),
          y: rect.top.toInt(),
          width: (rect.right - rect.left).toInt(),
          height: (rect.bottom - rect.top).toInt(),
        );
      }
      if ((editorOptions.rotation % 4) != 0) {
        image = img.copyRotate(image, angle: (editorOptions.rotation % 4) * 90);
      }

      return saveFile(image);
    }
    return null;
    /* if (state.getCropRect() != null) {
      final croppedImageRawData = await ImageProcessing.cropImageWithThread(
        imageBytes: state.rawImageData,
        rect: state.getCropRect()!,
      );
      if (croppedImageRawData != null) {
        return ImageProcessing.saveImageToCache(
          croppedImageRawData,
          editorOptions,
        );
      }
    } */
  }
}
