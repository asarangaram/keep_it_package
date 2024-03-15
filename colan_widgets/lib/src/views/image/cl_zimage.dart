import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class CLzImage extends StatefulWidget {
  const CLzImage({required this.file, super.key});
  final File file;

  @override
  State<CLzImage> createState() => _CLzImageState();
}

class _CLzImageState extends State<CLzImage> {
  late final PhotoViewController controller;
  double? scaleCopy;

  @override
  void initState() {
    super.initState();
    controller = PhotoViewController()..outputStateStream.listen(listener);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void listener(PhotoViewControllerValue value) {
    setState(() {
      scaleCopy = value.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: FileImage(widget.file),
            controller: controller,
          ),
        ),
        Text(
          'Scale applied: $scaleCopy',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
