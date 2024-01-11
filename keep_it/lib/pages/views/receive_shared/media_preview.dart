import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../load_from_store/load_image.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    required this.media,
    super.key,
    this.children,
    this.maxItems = 12,
    this.showAll = false,
  });

  factory MediaPreview.fromItems(Items items, {List<Widget>? children}) {
    final media = <CLMediaImage>[];
    for (final item in items.entries) {
      media.add(CLMediaImage(path: item.path, type: item.type));
    }
    return MediaPreview(media: media, children: children);
  }

  final List<CLMedia> media;
  final List<Widget>? children;
  final int maxItems;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllSupportedMedia = media.every(
      (element) =>
          [CLMediaType.image, CLMediaType.video].contains(element.type),
    );
    if (isAllSupportedMedia) {
      return Material(
        elevation: 6,
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CLGridViewCustom(
                maxItems: maxItems,
                showAll: showAll,

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
            ),
            if (children != null) ...children!,
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final e in media) ...[
              ShowAsText(text: e.path, type: e.type),
              const SizedBox(height: 16),
            ],
          ],
        ),
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

class VidoePlayIcon extends StatelessWidget {
  const VidoePlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(192), // Color for the circular container
      ),
      child: CLIcon.veryLarge(
        Icons.play_arrow_sharp,
        color: Theme.of(context).colorScheme.background.withAlpha(192),
      ),
    );
  }
}
