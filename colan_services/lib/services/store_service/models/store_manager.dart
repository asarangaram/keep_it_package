import 'dart:io';

import 'package:device_resources/device_resources.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:store/store.dart';

@immutable
class StoreManager {
  const StoreManager({
    required this.store,
    required this.appSettings,
  });
  final Store store;
  final AppSettings appSettings;

  Future<bool> generatePreview(
    String inputFile,
    String outputFile,
    CLMediaType type, {
    int dimension = 256,
  }) async {
    switch (type) {
      case CLMediaType.image:
        {
          final img.Image? inputImage;
          if (lookupMimeType(inputFile) == 'image/heic') {
            final jpegPath = await HeifConverter.convert(
              inputFile,
              output: '$inputFile.jpeg',
            );
            if (jpegPath == null) {
              throw Exception(' Failed to convert HEIC file to JPEG');
            }
            inputImage = img.decodeImage(File(jpegPath).readAsBytesSync());
          } else {
            inputImage = img.decodeImage(File(inputFile).readAsBytesSync());
          }
          if (inputImage == null) {
            return false;
          }

          final int thumbnailHeight;
          final int thumbnailWidth;
          if (inputImage.height > inputImage.width) {
            thumbnailHeight = dimension;
            thumbnailWidth =
                (thumbnailHeight * inputImage.width) ~/ inputImage.height;
          } else {
            thumbnailWidth = dimension;
            thumbnailHeight =
                (thumbnailWidth * inputImage.height) ~/ inputImage.width;
          }
          final thumbnail = img.copyResize(
            inputImage,
            width: thumbnailWidth,
            height: thumbnailHeight,
          );
          File(outputFile).writeAsBytesSync(
            Uint8List.fromList(img.encodeJpg(thumbnail)),
          );
        }

      case CLMediaType.video:
        final session = await FFmpegKit.execute(
          '-i $inputFile '
          '-vf '
          '"select=\'eq(pict_type,I)\',max,showinfo"'
          ' scale=$dimension:-1" '
          '-vframes 1 '
          '$outputFile',
        );
        /* final log = await session.getAllLogsAsString();
      print(log); */
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          return true;
        }

      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        break;
    }
    return false;
  }
}
