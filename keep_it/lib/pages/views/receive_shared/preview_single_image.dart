import 'dart:ui' as ui;
import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewSingleImage extends ConsumerWidget {
  const PreviewSingleImage({
    super.key,
    required this.imagePath,
  });
  final String imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(imageProvider(imagePath));
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: imageAsync.when(
            data: (ui.Image image) => RawImage(
                  image: image,
                  filterQuality: FilterQuality.high,
                ),
            loading: () => const CLLoadingView(),
            error: (err, _) => CLErrorView(errorMessage: err.toString())),
      ),
    );
  }
}
