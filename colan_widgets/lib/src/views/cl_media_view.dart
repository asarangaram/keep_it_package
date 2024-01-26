import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/media/cl_media.dart';

class CLMediaView extends StatelessWidget {
  const CLMediaView({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;
  @override
  Widget build(BuildContext context) {
    final imageFile = File(media.previewFileName);
    if (imageFile.existsSync()) {
      return AspectRatio(
        aspectRatio: 1,
        child: Image.file(
          imageFile,
          fit: !keepAspectRatio ? BoxFit.cover : null,
        ),
      );
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(2),
        child: FittedBox(
          child: SizedBox(
            width: 50 + 16,
            height: 50 + 16,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Preview Not Found',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
