import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageIncomingMedia extends ConsumerWidget {
  const PageIncomingMedia({
    required this.builder,
    super.key,
  });
  final IncomingMediaViewBuilder builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(
      sharedMediaInfoGroup,
    );

    return builder(
      context,
      ref,
      media: media,
      onDiscard: (media) {
        ref.read(incomingMediaProvider.notifier).pop();
      },
    );
  }
}
