import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../../internal/widgets/shimmer.dart';
import '../providers/media_storage.dart';

enum ImageViewFormat { preview, standard, original }

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri(
    this.media, {
    required this.builder,
    super.key,
  }) : dimensionPreset = ImageViewFormat.standard;
  const GetMediaUri.preview(
    this.media, {
    required this.builder,
    super.key,
  }) : dimensionPreset = ImageViewFormat.preview;
  const GetMediaUri.original(
    this.media, {
    required this.builder,
    super.key,
  }) : dimensionPreset = ImageViewFormat.original;
  final CLMedia media;
  final Widget Function(Uri uri) builder;
  final ImageViewFormat dimensionPreset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaStorageAsync = ref.watch(mediaFilesUriProvider(media));

    return mediaStorageAsync.when(
      data: (store) {
        return switch (dimensionPreset) {
          ImageViewFormat.preview => store.previewPath.when(
              data: builder,
              error: BrokenImage.show,
              loading: GreyShimmer.show,
            ),
          ImageViewFormat.standard => store.mediaPath.when(
              data: builder,
              error: BrokenImage.show,
              loading: GreyShimmer.show,
            ),
          ImageViewFormat.original => store.originalMediaPath.when(
              data: builder,
              error: BrokenImage.show,
              loading: GreyShimmer.show,
            ),
        };
      },
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }
}
