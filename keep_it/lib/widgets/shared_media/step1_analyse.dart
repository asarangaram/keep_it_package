import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';

import '../../models/store_manager.dart';

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
    return MediaHandlerWidget(
      builder: ({required action}) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: WizardLayout(
            title: 'Analysing Shared Media',
            onCancel: onCancel,
            child: StreamProgressView(
              stream: () => action.analyseMediaStream(
                media: incomingMedia,
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
