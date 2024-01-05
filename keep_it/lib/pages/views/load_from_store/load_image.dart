import 'dart:ui' as ui;

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadMediaImage extends ConsumerWidget {
  const LoadMediaImage({
    super.key,
    required this.mediaInfo,
    required this.onImageLoaded,
  });

  final Widget Function(ui.Image mediaData) onImageLoaded;
  final CLMediaInfo mediaInfo;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(imageProvider(mediaInfo));

    return imageAsync.when(
        data: (ui.Image data) => onImageLoaded(data),
        loading: () => const Center(child: CLLoadingView()),
        error: (err, _) =>
            Center(child: CLErrorView(errorMessage: err.toString())));
  }
}
