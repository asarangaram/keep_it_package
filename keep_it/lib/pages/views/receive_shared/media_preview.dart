import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../load_from_store/load_image.dart';
import '../video_player.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    required this.media,
    super.key,
    this.maxCrossAxisCount = 3,
    this.maxItems = 9,
    this.showAll = false,
  });

  factory MediaPreview.fromItems(
    Items items,
  ) {
    final media = <CLMediaImage>[];
    for (final item in items.entries) {
      media.add(CLMediaImage(path: item.path, type: item.type));
    }
    return MediaPreview(
      media: media,
    );
  }

  final List<CLMedia> media;
  final int maxCrossAxisCount;
  final int maxItems;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllSupportedMedia = media.every(
      (element) =>
          [CLMediaType.image, CLMediaType.video].contains(element.type),
    );
    if (isAllSupportedMedia) {
      final isLoading = ref.watch(isAnyMediaLoadingProvider(media));
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return SupportedMediaPreview(
        media: media,
        maxItems: maxItems,
        showAll: showAll,
        maxCrossAxisCount: maxCrossAxisCount,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final e in media) ...[
            ShowAsText(text: e.path, type: e.type),
            const SizedBox(height: 16),
          ],
        ],
      );
    }
  }
}

class ShowAsText extends ConsumerWidget {
  const ShowAsText({required this.text, super.key, this.type});
  final String text;
  final CLMediaType? type;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text.rich(
      TextSpan(
        children: [
          if (type != null)
            TextSpan(
              text: '${type!.name.toUpperCase()}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}

///
/// SupportedMediaType.video => ,

class SupportedMediaPreview extends ConsumerWidget {
  const SupportedMediaPreview({
    required this.media,
    super.key,
    this.maxCrossAxisCount = 2,
    this.maxItems = 9,
    this.showAll = false,
  });
  final List<CLMedia> media;
  final int maxCrossAxisCount;
  final int maxItems;
  final bool showAll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: 6,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: CLGridViewCustom(
        maxItems: maxItems,
        showAll: showAll,
        maxCrossAxisCount: maxCrossAxisCount,

        // backgroundColor: Colors.blue,
        children: media
            .map(
              (e) => [
                switch (e.type) {
                  CLMediaType.image || CLMediaType.video => LoadMedia(
                      mediaInfo: e,
                      onMediaLoaded: (media) {
                        return CLImageViewer(
                          image: media.preview!,
                          allowZoom: false,
                          overlayWidget: switch (e.type) {
                            CLMediaType.video => const VidoePlayIcon(),
                            _ => null
                          },
                        );
                      },
                    ),
                  /* SupportedMediaType.video =>
                    VideoPlayerScreen(path: e.key),*/
                  _ => throw Exception('Unexpected')
                },
              ],
            )
            .toList(),
      ),
    );
  }
}

final isAnyMediaLoadingProvider =
    StateProvider.family<bool, List<CLMedia>>((ref, media) {
  final isLoading = <bool>[];
  for (final e in media) {
    final m = ref.watch(mediaProvider(e));
    isLoading.add(m.isLoading);
  }

  return isLoading.any((element) => element);
});
