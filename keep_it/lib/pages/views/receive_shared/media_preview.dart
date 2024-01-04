import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/receive_shared/preview_single_image.dart';
import 'package:store/store.dart';

import '../video_player.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    super.key,
    required this.media,
    this.children,
  });
  final Map<String, SupportedMediaType> media;
  final List<Widget>? children;
  factory MediaPreview.fromItems(Items items, {List<Widget>? children}) {
    Map<String, SupportedMediaType> media = {};
    for (var item in items.entries) {
      media[item.path] = item.type;
    }
    return MediaPreview(media: media, children: children);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = ref.watch(themeProvider);
    if (media.length == 1) {
      MapEntry<String, SupportedMediaType> e = media.entries.first;
      return switch (e.value) {
        SupportedMediaType.image => Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16.0), // Adjust the radius as needed
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: PreviewSingleImage(imagePath: e.key)),
                    ),
                  ),
                  if (children != null) ...children!
                ],
              ),
            ),
          ),
        SupportedMediaType.video => VideoPlayerScreen(
            path: e.key,
          ),
        _ => ShowAsText(text: e.key, type: e.value)
      };
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
