import 'dart:io';

import 'package:flutter/material.dart';

import '../models/cl_media.dart';

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
    return AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 60 + 16,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Text(
                  'Preview Not Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
