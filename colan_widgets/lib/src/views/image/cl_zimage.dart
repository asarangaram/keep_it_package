import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CLzImage extends StatelessWidget {
  const CLzImage({required this.file, super.key});
  final File file;

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      minScale: PhotoViewComputedScale.contained,
      imageProvider: FileImage(file),
    );
  }
}
