import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'wizard_page.dart';

class SaveCollection extends SharedMediaWizard {
  const SaveCollection({
    required super.incomingMedia,
    required super.onDone,
    required super.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return StreamProgressView(
          stream: () => dbManager.upsertCollectionWithMedia(
            collection: incomingMedia.collection!,
            newTagsListToReplace: incomingMedia.tags == null
                ? null
                : List.from(incomingMedia.tags!),
            media: List.from(incomingMedia.entries),
            onDone: () {
              onDone(mg: null);
            },
          ),
          onCancel: onCancel,
        );
      },
    );
  }
}
