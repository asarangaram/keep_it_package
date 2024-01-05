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
    Map<String, SupportedMediaType> media = {};
    for (var item in items.entries) {
      media[item.path] = item.type;
    }
    return MediaPreview(media: media, children: children);
  }

  final Map<String, SupportedMediaType> media;
  final List<Widget>? children;
  final int maxItems;
  final bool showAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllImages = media.values.every(
      (element) => [SupportedMediaType.image, SupportedMediaType.video]
          .contains(element),
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
                  children: media.entries
                      .map(
                        (e) => switch (e.value) {
                          SupportedMediaType.image ||
                          SupportedMediaType.video =>
                            LoadMediaImage(
                              mediaEntry: e,
                              onImageLoaded: (image) {
                                return CLImageViewer(
                                  image: image,
                                  allowZoom: false,
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
            for (final e in media.entries) ...[
              ShowAsText(text: e.key, type: e.value),
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
  final SupportedMediaType? type;
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

