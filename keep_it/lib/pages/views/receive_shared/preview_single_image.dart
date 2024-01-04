/* import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  const ImageCard(
    this.image, {
    super.key,
  });
  final ui.Image image;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.yellow, width: 8)),
        child: Card(
          elevation: 8,
          color: Colors.grey,
          shadowColor: Colors.grey,
          surfaceTintColor: Colors.grey..withOpacity(0.5),
          margin: EdgeInsets.zero,
          child: SizedBox(
            width: image.width.toDouble(),
            height: image.height.toDouble(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: RawImage(
                image: image,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */