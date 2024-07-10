import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../store_manager.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required CLSharedMedia? mg}) onDone;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return StoreManager(
      builder: ({required storeAction}) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: WizardLayout(
            title: 'Analysing Shared Media',
            onCancel: onCancel,
            child: StreamProgressView(
              stream: () => storeAction.analyseMediaStream(
                media: incomingMedia.entries,
                onDone: ({required List<CLMedia> mg}) {
                  onDone(mg: incomingMedia.copyWith(entries: mg));
                },
              ),
              onCancel: onCancel,
            ),
          ),
        );
      },
    );
  }
}
