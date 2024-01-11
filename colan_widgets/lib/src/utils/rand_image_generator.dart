import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RandomImage {
  static final random = Random();

  static Future<ui.Image> generateImage() async {
    const aspectRatio = 1.2; // (random.nextInt(500).toDouble() / 100) + 0.7;

    final width = (100 + aspectRatio * 200).toInt();
    final height = width ~/ aspectRatio;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset.zero,
        Offset(width.toDouble(), height.toDouble()),
      ),
    );

    final whitePaint = Paint()
      ..color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      whitePaint,
    );

    final numShapes = random.nextInt(6) + 3;

    for (var j = 0; j < numShapes; j++) {
      final shape = random.nextInt(3);
      final fillColor = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      switch (shape) {
        case 0:
          final radius = random.nextInt(min(width, height) ~/ 4);
          final x = random.nextInt(width - 2 * radius);
          final y = random.nextInt(height - 2 * radius);
          final circlePaint = Paint()..color = fillColor;
          canvas.drawCircle(
            Offset(x + radius.toDouble(), y + radius.toDouble()),
            radius.toDouble(),
            circlePaint,
          );
        case 1:
          final side = random.nextInt(min(width, height) ~/ 2);
          final x = random.nextInt(width - side);
          final y = random.nextInt(height - side);
          final rect = Rect.fromLTWH(
            x.toDouble(),
            y.toDouble(),
            side.toDouble(),
            side.toDouble(),
          );
          final rectPaint = Paint()..color = fillColor;
          canvas.drawRect(rect, rectPaint);
        case 2:
          final rectWidth = random.nextInt(width ~/ 2);
          final rectHeight = random.nextInt(height ~/ 2);
          final x = random.nextInt(width - rectWidth);
          final y = random.nextInt(height - rectHeight);
          final rect = Rect.fromLTWH(
            x.toDouble(),
            y.toDouble(),
            rectWidth.toDouble(),
            rectHeight.toDouble(),
          );
          final rectPaint = Paint()..color = fillColor;
          canvas.drawRect(rect, rectPaint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    return image;
  }

  static Future<List<ui.Image>> generateImages(int numImages) async {
    final images = <ui.Image>[];

    for (var i = 0; i < numImages; i++) {
      images.add(await generateImage());
    }

    return images;
  }

  static List<List<ui.Image>> columnizeImages(
    List<ui.Image> images, {
    int numberOfColumns = 3,
    bool byHeight = true,
  }) {
    final columnizedImages =
        List<List<ui.Image>>.generate(numberOfColumns, (index) => []);
    final heights = List<int>.generate(numberOfColumns, (index) => 0);
    final numberOfImages = images.length;

    for (var img = 0; img < numberOfImages; img++) {
      final minIndex = heights
          .asMap()
          .entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;

      columnizedImages[minIndex].add(images[img]);
      heights[minIndex] += images[img].height + 16;
    }
    return columnizedImages;
  }
}
