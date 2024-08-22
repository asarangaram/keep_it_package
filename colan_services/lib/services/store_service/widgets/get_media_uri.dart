import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../../internal/widgets/shimmer.dart';
import '../providers/media_storage.dart';

enum ImageDimensionPreset { previewDimension, standardDimension, original }

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri(
    this.media, {
    required this.builder,
    super.key,
  }) : dimensionPreset = ImageDimensionPreset.standardDimension;
  const GetMediaUri.preview(
    this.media, {
    required this.builder,
    super.key,
  }) : dimensionPreset = ImageDimensionPreset.previewDimension;
  const GetMediaUri.original(
    this.media, {
    required this.builder,
    super.key,
  }) : dimensionPreset = ImageDimensionPreset.original;
  final CLMedia media;
  final Widget Function(Uri uri) builder;
  final ImageDimensionPreset dimensionPreset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaStorageAsync = ref.watch(mediaStorageProvider(media));

    return mediaStorageAsync.when(
      data: (store) {
        return switch (dimensionPreset) {
          ImageDimensionPreset.previewDimension => store.previewPath.when(
              data: builder,
              error: BrokenImage.show,
              loading: GreyShimmer.show,
            ),
          ImageDimensionPreset.standardDimension => store.mediaPath.when(
              data: builder,
              error: BrokenImage.show,
              loading: GreyShimmer.show,
            ),
          ImageDimensionPreset.original => store.originalMediaPath.when(
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
