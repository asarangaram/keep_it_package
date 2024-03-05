import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../widgets/editors/collection_editor_wizard/create_collection_wizard.dart';
import 'wizard_page.dart';

class WhichCollection extends SharedMediaWizard {
  const WhichCollection({
    required super.incomingMedia,
    required super.onDone,
    required super.onCancel,
    super.key,
    this.title,
  });
  final Widget? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetTagMultiple(
      buildOnData: (tags) => Column(
        children: [
          if (title != null) title!,
          if (incomingMedia.entries.length == 1)
            Flexible(
              child: CLMediaPreview(
                media: incomingMedia.entries[0],
              ),
            )
          else
            Flexible(
              child: CLMediaCollage.byMatrixSize(
                incomingMedia.entries,
                hCount: switch (incomingMedia.entries.length) { _ => 2 },
                itemBuilder: (context, index) => CLMediaPreview(
                  media: incomingMedia.entries[index],
                ),
              ),
            ),
          const Divider(
            thickness: 4,
          ),
          SizedBox(
            height: kMinInteractiveDimension * 4,
            child: CreateCollectionWizard(
              onDone: ({required collection, required tags}) {
                onDone(
                  mg: incomingMedia.copyWith(
                    collection: collection,
                    tags: tags,
                    entries: incomingMedia.entries
                        .map((e) => e.copyWith(collectionId: collection.id))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
