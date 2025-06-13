import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../../../models/cl_media_candidate.dart';
import 'stream_progress_view.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.store,
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final void Function({
    required ViewerEntities existingEntities,
    required ViewerEntities newEntities,
    required List<CLMediaContent> invalidContent,
  })? onDone;
  final void Function() onCancel;
  final CLStore store;

  @override
  Widget build(BuildContext context) {
    return WizardLayout(
      title: 'Analysing Shared Media',
      onCancel: onCancel,
      child: StreamProgressView(
        stream: () => store.getValidMediaFiles(
          contentList: incomingMedia.entries,
          onDone: onDone,
        ),
        onCancel: onCancel,
      ),
    );
  }
}
