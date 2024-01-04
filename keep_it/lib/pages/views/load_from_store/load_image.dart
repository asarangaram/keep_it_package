import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class LoadMediaImage extends ConsumerWidget {
  const LoadMediaImage(
      {super.key,
      required this.path,
      required this.onImageLoaded,
      required this.type});
  final String path;
  final Widget Function(ImageData mediaData) onImageLoaded;
  final SupportedMediaType type;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(imageProvider(path));

    return imageAsync.when(
        data: (MediaData data) => onImageLoaded(data as ImageData),
        loading: () => const Center(child: CLLoadingView()),
        error: (err, _) => CLErrorView(errorMessage: err.toString()));
  }
}
