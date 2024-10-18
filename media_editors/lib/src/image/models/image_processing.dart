import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

class ImageProcessing {
  static Future<bool> imageCropper(
    Uint8List imageBytes, {
    required String outFile,
    Rect? cropRect,
    bool needFlip = false,
    double? rotateAngle,
  }) async {
    try {
      var image = img.decodeImage(imageBytes);
      if (image == null) return false;

      if (cropRect != null) {
        image = img.copyCrop(
          image,
          x: cropRect.left.ceil(),
          y: cropRect.top.ceil(),
          width: (cropRect.right - cropRect.left).ceil(),
          height: (cropRect.bottom - cropRect.top).ceil(),
        );
      }
      if (needFlip) {
        image = img.flipHorizontal(image);
      }
      if (rotateAngle != null) {
        image = img.copyRotate(image, angle: rotateAngle);
      }
      await img.encodeJpgFile(outFile, image);
      return true;
    } catch (e) {
      return false;
    }
  }
}
