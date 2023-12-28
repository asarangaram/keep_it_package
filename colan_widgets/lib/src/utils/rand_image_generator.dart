import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math';

class RandomImageGenerator {
  Uint8List image;
  int width;
  int height;
  static final random = Random();
  RandomImageGenerator({
    required this.image,
    required this.width,
    required this.height,
  });

  static Future<RandomImageGenerator> generateImage(
      {double? aspectRatio}) async {
    aspectRatio = aspectRatio ?? 1.0;
    final width = (100 + aspectRatio * 200).toInt();
    final height = width ~/ aspectRatio;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0, 0), Offset(width.toDouble(), height.toDouble())));

    final whitePaint = Paint()
      ..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), whitePaint);

    final numShapes = random.nextInt(6) + 3;

    for (var j = 0; j < numShapes; j++) {
      final shape = random.nextInt(3);
      final fillColor = Color.fromARGB(
          255, random.nextInt(256), random.nextInt(256), random.nextInt(256));

      switch (shape) {
        case 0:
          final radius = random.nextInt(width ~/ 4);
          final x = random.nextInt(width - 2 * radius);
          final y = random.nextInt(height - 2 * radius);
          final circlePaint = Paint()..color = fillColor;
          canvas.drawCircle(
              Offset(x + radius.toDouble(), y + radius.toDouble()),
              radius.toDouble(),
              circlePaint);
          break;
        case 1:
          final side = random.nextInt(width ~/ 2);
          final x = random.nextInt(width - side);
          final y = random.nextInt(height - side);
          final rect = Rect.fromLTWH(
              x.toDouble(), y.toDouble(), side.toDouble(), side.toDouble());
          final rectPaint = Paint()..color = fillColor;
          canvas.drawRect(rect, rectPaint);
          break;
        case 2:
          final rectWidth = random.nextInt(width ~/ 2);
          final rectHeight = random.nextInt(height ~/ 2);
          final x = random.nextInt(width - rectWidth);
          final y = random.nextInt(height - rectHeight);
          final rect = Rect.fromLTWH(x.toDouble(), y.toDouble(),
              rectWidth.toDouble(), rectHeight.toDouble());
          final rectPaint = Paint()..color = fillColor;
          canvas.drawRect(rect, rectPaint);
          break;
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return RandomImageGenerator(
        image: byteData!.buffer.asUint8List(), width: width, height: height);
  }

  static Future<List<RandomImageGenerator>> generateImages(
      int numImages) async {
    final List<RandomImageGenerator> images = [];

    for (var i = 0; i < numImages; i++) {
      final aspectRatio = 0.7 + (1.3 - 0.7) * (i / numImages);
      images.add(await generateImage(aspectRatio: aspectRatio));
    }

    return images;
  }
}
