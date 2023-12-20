import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/receive_shared/preview_single_image.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    super.key,
    required this.media,
  });
  final Map<String, SupportedMediaType> media;

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
              padding: const EdgeInsets.all(1.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: PreviewSingleImage(imagePath: e.key)),
            ),
          ),
        _ => ShowAsText(text: e.key, type: e.value)
      };
    } else {
      return Column(
        children: [
          for (final e in media.entries) ...[
            ShowAsText(text: e.key, type: e.value),
            const SizedBox(height: 16),
          ]
        ],
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
