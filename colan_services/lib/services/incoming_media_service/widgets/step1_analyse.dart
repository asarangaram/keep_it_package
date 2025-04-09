import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final void Function({
    required List<StoreEntity> existingItems,
    required List<StoreEntity> newItems,
  }) onDone;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: WizardLayout(
        title: 'Analysing Shared Media',
        onCancel: onCancel,
        child: StreamProgressView(
          stream: () => throw Exception('Unimplemented')
          /* theStore.mediaUpdater.analyseMultiple(
                mediaFiles: incomingMedia.entries,
                onDone: onDone,
              ) */
          ,
          onCancel: onCancel,
        ),
      ),
    );
  }
}
