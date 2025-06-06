import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';

import 'package:store/store.dart';

import '../../../models/cl_media_candidate.dart';
import 'stream_progress_view.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.incomingMedia,
    required this.onDone,
    required this.onCancel,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final void Function({
    required List<StoreEntity> existingEntities,
    required List<StoreEntity> newEntities,
    required List<CLMediaContent> invalidContent,
  })? onDone;
  final void Function() onCancel;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GetActiveStore(
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        builder: (store) {
          return WizardLayout(
            title: 'Analysing Shared Media',
            onCancel: onCancel,
            child: StreamProgressView(
              stream: () => store.getValidMediaFiles(
                contentList: incomingMedia.entries,
                collection: incomingMedia.collection,
                onDone: onDone,
              ),
              onCancel: onCancel,
            ),
          );
        },
      ),
    );
  }
}
