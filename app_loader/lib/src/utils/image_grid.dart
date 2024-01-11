import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageGrid {
  ImageGrid(this.images, {this.cellWidth = 64, this.cellHeight = 64});
  final List<ui.Image> images;
  final int cellWidth;
  final int cellHeight;

  static Future<ui.Image> imageGrid4(
    ui.Image image0,
    ui.Image image1,
    ui.Image image2,
    ui.Image image3, {
    int cellWidth = 64,
    int cellHeight = 64,
  }) async {
    final topLeft =
        await ImageGrid.createThumbnail(image0, cellWidth, cellHeight);
    final topRight =
        await ImageGrid.createThumbnail(image1, cellWidth, cellHeight);
    final bottomLeft =
        await ImageGrid.createThumbnail(image2, cellWidth, cellHeight);
    final bottomRight = await ImageGrid.createThumbnail(image3, cellWidth, 64);

    final top = await ImageGrid.concatenateImagesHorizontal(topLeft, topRight);
    final bottom =
        await ImageGrid.concatenateImagesHorizontal(bottomLeft, bottomRight);

    return ImageGrid.concatenateImagesVertically(top, bottom);
  }

  static Future<ui.Image> createThumbnail(
    ui.Image originalImage,
    int thumbnailWidth,
    int thumbnailHeight,
  ) async {
    final recorder = ui.PictureRecorder();
    Canvas(
      recorder,
      Rect.fromPoints(
        Offset.zero,
        Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble()),
      ),
    ).drawImageRect(
      originalImage,
      Rect.fromPoints(
        Offset.zero,
        Offset(
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
      ),
      Rect.fromPoints(
        Offset.zero,
        Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble()),
      ),
      Paint(),
    );

    final picture = recorder.endRecording();
    final thumbnailImage =
        await picture.toImage(thumbnailWidth, thumbnailHeight);
    return thumbnailImage;
  }

  static Future<ui.Image> concatenateImagesHorizontal(
    ui.Image image1,
    ui.Image image2,
  ) async {
    final width = image1.width + image2.width;
    final height = image1.height; // Assuming both images have the same height

    // Create a blank image to hold the concatenated images
    final recorder = ui.PictureRecorder();
    Canvas(
      recorder,
      Rect.fromPoints(
        Offset.zero,
        Offset(width.toDouble(), height.toDouble()),
      ),
    )
      ..drawImage(image1, Offset.zero, Paint())
      ..drawImage(image2, Offset(image1.width.toDouble(), 0), Paint());

    // Finish recording the picture
    final picture = recorder.endRecording();

    // Convert the picture to an image

    return picture.toImage(width, height);
  }

  static Future<ui.Image> concatenateImagesVertically(
    ui.Image image1,
    ui.Image image2,
  ) async {
    final resultWidth = image1.width;
    final resultHeight = image1.height + image2.height;

    final recorder = ui.PictureRecorder();
    Canvas(
      recorder,
      Rect.fromPoints(
        Offset.zero,
        Offset(resultWidth.toDouble(), resultHeight.toDouble()),
      ),
    )
      ..drawImage(image1, Offset.zero, Paint())
      ..drawImage(image2, Offset(0, image1.height.toDouble()), Paint());

    final picture = recorder.endRecording();
    final resultImage = await picture.toImage(resultWidth, resultHeight);
    return resultImage;
  }
}
