import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class PinnedMediaPage extends ConsumerWidget {
  const PinnedMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetPinnedMedia(
      buildOnData: (media) {
        if (media.isNotEmpty) {
          return Center(
            child: CLText.large(
              'You have pinned Media (${media.length})',
            ),
          );
        }
        return const Center(
          child: CLText.large(
            'The medias pinned to show in gallery are listed here.',
          ),
        );
      },
    );
  }
}
