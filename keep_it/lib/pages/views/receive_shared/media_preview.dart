import 'package:app_loader/app_loader.dart';
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
    final isAllImages = media.values.every(
      (element) => element == SupportedMediaType.image,
    );
    if (isAllImages) {
      MapEntry<String, SupportedMediaType> e = media.entries.first;
      return Card(
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
                  child: RowColumn(
                children: media.entries
                    .map(
                      (e) => PreviewSingleImage(imagePath: e.key),
                    )
                    .toList(),
              )),
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

/**
 * 
 * SupportedMediaType.video => VideoPlayerScreen(
            path: e.key,
          ),
 */

class RowColumn extends ConsumerWidget {
  final List<Widget> children;
  const RowColumn({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hCount = switch (children.length) {
      1 => 1,
      < 6 => 2,
      _ => 3,
    };
    final items2D = children.convertTo2D(hCount);
    return Column(
      children: [
        for (var r in items2D)
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < r.length; index++)
                  Flexible(child: r[index]),
                /* for (var index = r.length; index < hCount; index++)
                  Flexible(
                    child: Container(),  )*/
              ],
            ),
          )
      ],
    );
  }
}
