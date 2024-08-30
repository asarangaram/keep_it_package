import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:store/store.dart';

import '../models/store_manager.dart';

extension UtilsOnStoreManager on StoreManager {
  Future<bool> generatePreview(
    CLMedia media, {
    int dimension = 256,
  }) async {
    final inputFile = getMediaFileName(media);
    final outputFile = getPreviewFileName(media);
    final type = media.type;

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
          return true;
        }

      case CLMediaType.video:
        await File(outputFile).deleteIfExists();
        final session = await FFmpegKit.execute(
          '-i $inputFile '
          '-ss 00:00:01.000 '
          '-vframes 1 '
          '-vf "scale=$dimension:-1" '
          '$outputFile',
        );
        /* final log = await session.getAllLogsAsString();
      print(log); */
        final returnCode = await session.getReturnCode();

        return ReturnCode.isSuccess(returnCode);

      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        break;
    }
    return false;
  }
}
