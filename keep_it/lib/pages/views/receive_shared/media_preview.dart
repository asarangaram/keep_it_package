// ignore: unused_import
import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class MediaPreview extends ConsumerWidget {
  const MediaPreview({
    required this.media,
    super.key,
    this.columns = 3,
    this.rows,
  });

  factory MediaPreview.fromItems(
    Items items, {
    int columns = 1,
    int? rows,
  }) {
    final media = <CLMediaImage>[];
    for (final item in items.entries) {
      media.add(CLMediaImage(path: item.path, type: item.type));
    }
    return MediaPreview(
      media: media,
      columns: columns,
      rows: rows,
    );
  }

  final List<CLMedia> media;
  final int columns;
  final int? rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllSupportedMedia = media.every(
      (element) =>
          [CLMediaType.image, CLMediaType.video].contains(element.type),
    );
    if (isAllSupportedMedia) {
      return SupportedMediaPreview(
        media: media,
        columns: columns,
        rows: rows,
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

class SupportedMediaPreview extends ConsumerWidget {
  const SupportedMediaPreview({
    required this.media,
    super.key,
    this.rows,
    this.columns = 3,
  });
  final List<CLMedia> media;

  final int? rows;
  final int columns;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAll = rows == null;
    if (columns <= 0) {
      return const CLErrorView(errorMessage: 'Atleast one coumn must present');
    }
    if (showAll) {
      return CLMatrix2DScrollable(
        hCount: columns,
        vCount: (media.length + columns - 1) ~/ columns,
        itemBuilder: itemBuilder,
      );
    }
    final excess = media.length - rows! * columns;
    return CLMatrix2D(
      hCount: columns,
      vCount: rows!,
      trailingRow:
          (excess <= 0) ? null : Center(child: CLText.small('+$excess Items')),
      itemBuilder: itemBuilder,
    );
  }

  Widget itemBuilder(BuildContext context, int r, int c, int l) {
    if (l > 0) {
      throw Exception('has only one layer!');
    }
    if ((r * columns + c) >= media.length) {
      return const Center(
        child: Text('Empty'),
      );
    }
    final e = media[r * columns + c];
    final image = File(e.previewFileName);
    if (image.existsSync()) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Image.file(image),
        ),
      );
    }
    return const Center(
      child: Text('Preview Not Found'),
    );
    /* return FutureBuilder(
      future: e.getImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CLIcon.small(Icons.timer));
        }
        if (snapshot.data == null) {
          return const CLIcon.large(Icons.abc);
        }
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Center(child: RawImage(image: snapshot.data)),
        );
      },
    ); */
  }
}
