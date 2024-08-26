import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

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
}
