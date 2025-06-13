/* import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../models/content_origin.dart';
import '../providers/universal_media.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.type,
    required this.onSelectionChanged,
    super.key,
  });

  final ContentOrigin type;
  final void Function(ViewerEntities)? onSelectionChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  StoreEntity? previewItem;

  ContentOrigin get type => widget.type;

  void Function(ViewerEntities)? get onSelectionChanged =>
      widget.onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final media0 = ref.watch(universalMediaProvider(type));
    if (media0.isEmpty) {
      throw Exception('Nothing to show');
    }

    return CLEntitiesGridView(
      incoming: media0.entries,
      filtersDisabled: true,
      whenEmpty: const SizedBox.shrink(), // FIXME

      // Wizard don't use context menu
      contextMenuBuilder: null,
      onSelectionChanged: onSelectionChanged == null
          ? null
          : (items) => onSelectionChanged?.call(items),
      itemBuilder: (context, item, entities) {
        if (item.isCollection) {
          throw UnimplementedError();
          /* return CollectionPreview.preview(
            item as StoreEntity,
          ); */
        }
        return MediaThumbnail(
          media: item as StoreEntity,
        );
      },
    );
  }
}
 */
