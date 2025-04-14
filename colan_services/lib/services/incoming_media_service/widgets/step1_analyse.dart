import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import 'stream_progress_view.dart';

class AnalysePage extends StatelessWidget {
  const AnalysePage({
    required this.storeIdentity,
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
  final String storeIdentity;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GetStore(
        storeIdentity: storeIdentity,
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
