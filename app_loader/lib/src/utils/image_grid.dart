import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageGrid {
  final List<ui.Image> images;
  final int cellWidth;
  final int cellHeight;
  ImageGrid(this.images, {this.cellWidth = 64, this.cellHeight = 64});

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

    return await ImageGrid.concatenateImagesVertically(top, bottom);
  }

  static Future<ui.Image> createThumbnail(
      ui.Image originalImage, int thumbnailWidth, int thumbnailHeight) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0.0, 0.0),
            Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble())));
    canvas.drawImageRect(
        originalImage,
        Rect.fromPoints(
            const Offset(0.0, 0.0),
            Offset(originalImage.width.toDouble(),
                originalImage.height.toDouble())),
        Rect.fromPoints(const Offset(0.0, 0.0),
            Offset(thumbnailWidth.toDouble(), thumbnailHeight.toDouble())),
        Paint());

    final ui.Picture picture = recorder.endRecording();
    final ui.Image thumbnailImage =
        await picture.toImage(thumbnailWidth, thumbnailHeight);
    return thumbnailImage;
  }

  static Future<ui.Image> concatenateImagesHorizontal(
      ui.Image image1, ui.Image image2) async {
    int width = image1.width + image2.width;
    int height = image1.height; // Assuming both images have the same height

    // Create a blank image to hold the concatenated images
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0.0, 0.0),
            Offset(width.toDouble(), height.toDouble())));

    // Draw the first image on the canvas
    canvas.drawImage(image1, const Offset(0.0, 0.0), Paint());

    // Draw the second image next to the first one
    canvas.drawImage(image2, Offset(image1.width.toDouble(), 0.0), Paint());

    // Finish recording the picture
    final ui.Picture picture = recorder.endRecording();

    // Convert the picture to an image

    return await picture.toImage(width, height);
  }

  static Future<ui.Image> concatenateImagesVertically(
      ui.Image image1, ui.Image image2) async {
    int resultWidth = image1.width;
    int resultHeight = image1.height + image2.height;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromPoints(
        const Offset(0.0, 0.0),
        Offset(resultWidth.toDouble(), resultHeight.toDouble()),
      ),
    );

    canvas.drawImage(image1, const Offset(0.0, 0.0), Paint());
    canvas.drawImage(image2, Offset(0.0, image1.height.toDouble()), Paint());

    final ui.Picture picture = recorder.endRecording();
    final ui.Image resultImage =
        await picture.toImage(resultWidth, resultHeight);
    return resultImage;
  }
}
