import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../load_from_store/load_image.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    super.key,
    required this.media,
    this.children,
    this.maxItems = 12,
    this.showAll = false,
  });

  factory MediaPreview.fromItems(Items items, {List<Widget>? children}) {
    List<CLMediaInfo> media = [];
    for (var item in items.entries) {
      media.add(CLMediaInfo(path: item.path, type: item.type));
    }
    return MediaPreview(media: media, children: children);
  }

  final List<CLMediaInfo> media;
  final List<Widget>? children;
  final int maxItems;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllImages = media.every(
      (element) =>
          [CLMediaType.image, CLMediaType.video].contains(element.type),
    );
    if (isAllImages) {
      return Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 2.0, color: Color.fromARGB(255, 192, 192, 192)))),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(
          bottom: 16,
          left: 8,
          right: 8,
        ),
        alignment: Alignment.center,
        child: Material(
          elevation: 6.0,
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: CLGridViewCustom(
                  maxItems: maxItems,
                  showAll: showAll,
                  children: media
                      .map(
                        (e) => switch (e.type) {
                          CLMediaType.image ||
                          CLMediaType.video =>
                            LoadMediaImage(
                              mediaInfo: e,
                              onImageLoaded: (image) {
                                return Center(
                                  child: AspectRatio(
                                    aspectRatio: image.width / image.height,
                                    child: CLImageViewer(
                                      image: image,
                                      allowZoom: false,
                                      overlayWidget: switch (e.type) {
                                        CLMediaType.video =>
                                          const VidoePlayIcon(),
                                        _ => null
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          /* SupportedMediaType.video =>
                            VideoPlayerScreen(path: e.key),*/
                          _ => throw Exception("Unexpected")
                        },
                      )
                      .toList(),
                ),
              ),
              if (children != null) ...children!
            ],
          ),
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
            ]
          ],
        ),
      );
    }
  }
}

class ShowAsText extends ConsumerWidget {
  const ShowAsText({super.key, required this.text, this.type});
  final String text;
  final CLMediaType? type;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text.rich(TextSpan(children: [
      if (type != null)
        TextSpan(
            text: "${type!.name.toUpperCase()}: ",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      TextSpan(text: text)
    ]));
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
