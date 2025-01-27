import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/cl_shared_media.dart';

class AnalysePage extends ConsumerWidget {
  const AnalysePage({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final void Function({
    required List<CLMedia> existingItems,
    required List<CLMedia> newItems,
  }) onDone;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: WizardLayout(
            title: 'Analysing Shared Media',
            onCancel: onCancel,
            child: StreamProgressView(
              stream: () => theStore.mediaUpdater.analyseMultiple(
                mediaFiles: incomingMedia.entries,
                onDone: onDone,
              ),
              onCancel: onCancel,
            ),
          ),
        );
      },
    );
  }
}
