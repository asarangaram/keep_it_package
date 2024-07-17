import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: WizardLayout(
        title: 'Analysing Shared Media',
        onCancel: onCancel,
        child: StreamProgressView(
          stream: () => TheStore.of(context).newMediaMultipleStream(
            mediaFiles: incomingMedia.entries,
            onDone: ({required List<CLMedia> mediaMultiple}) {
              onDone(
                mg: CLSharedMedia(
                  entries: mediaMultiple,
                  collection: incomingMedia.collection,
                  type: incomingMedia.type,
                ),
              );
            },
          ),
          onCancel: onCancel,
        ),
      ),
    );
  }
}
