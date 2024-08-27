import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../../internal/widgets/shimmer.dart';
import '../providers/a0_media_uri.dart';
import '../providers/a1_preview_uri.dart';

/* enum ImageViewFormat { preview, standard, original }

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
    return builder(Uri.parse(''));
    // FIXME
    /* return ref.watch(mediaFilesUriProvider(media)).when(
          data: (filesUri) {
            final uri = switch (dimensionPreset) {
              ImageViewFormat.preview => filesUri.previewPath,
              ImageViewFormat.standard => filesUri.mediaPath,
              ImageViewFormat.original => filesUri.originalMediaPath,
            };
            if (uri == null) return GreyShimmer.show();
            return builder(uri);
          },
          error: BrokenImage.show,
          loading: GreyShimmer.show,
        ); */
  }
} */

class GetPreviewUri extends ConsumerWidget {
  const GetPreviewUri(this.media, {required this.builder, super.key});
  final Widget Function(Uri uri) builder;
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(previewUriProvider(media));
    return asyncValue.when(
      data: builder,
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }
}

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri(this.media, {required this.builder, super.key});
  final Widget Function(Uri uri) builder;
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(mediaUriProvider(media));
    return asyncValue.when(
      data: builder,
      error: BrokenImage.show,
      loading: GreyShimmer.show,
    );
  }
}
