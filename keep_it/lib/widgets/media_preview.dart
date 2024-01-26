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
          Center(child: CLText.small('+$excessCount Items')),
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
    return Align(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: CLMediaView(media: e),
      ),
    );
  }
}
