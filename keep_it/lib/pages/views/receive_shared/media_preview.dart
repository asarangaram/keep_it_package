// ignore: unused_import
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    required this.media,
    super.key,
    this.columns = 3,
    this.rows,
  });

  final List<CLMedia> media;
  final int columns;
  final int? rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLMatrix2D(
      itemCount: media.length,
      columns: columns,
      rows: rows,
      itemBuilder: itemBuilder,
      excessViewBuilder: (BuildContext context, int excessCount) =>
          DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.onTertiaryContainer),
          ],
        ),
        child: Center(child: CLText.small('+$excessCount Items')),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index, int layer) {
    if (layer > 0) {
      throw Exception('has only one layer!');
    }
    if (index > media.length) {
      throw Exception('index exceeded length');
    }
    final e = media[index];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.onTertiaryContainer),
        ],
      ),
      child: Align(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: MediaItemView(mediaItem: e),
        ),
      ),
    );
  }
}

class MediaItemView extends ConsumerWidget {
  const MediaItemView({required this.mediaItem, super.key});
  final CLMedia mediaItem;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = File(mediaItem.previewFileName);
    if (imageFile.existsSync()) {
      return Image.file(imageFile);
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(2),
        child: FittedBox(
          child: SizedBox(
            width: 50 + 16,
            height: 40 * 1.4 + 16,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Preview Not Found',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
