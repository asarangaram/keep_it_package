import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../models/universal_media_source.dart';
import '../../../providers/universal_media.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import '../../entity_viewer_service/models/entity_actions.dart';
import '../../entity_viewer_service/widgets/preview/collection_preview.dart';
import '../../entity_viewer_service/widgets/when_empty.dart';

class WizardPreview extends ConsumerStatefulWidget {
  const WizardPreview({
    required this.viewIdentifier,
    required this.type,
    required this.onSelectionChanged,
    super.key,
  });
  final UniversalMediaSource type;
  final void Function(List<StoreEntity>)? onSelectionChanged;

  final ViewIdentifier viewIdentifier;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPreviewState();
}

class _WizardPreviewState extends ConsumerState<WizardPreview> {
  StoreEntity? previewItem;

  UniversalMediaSource get type => widget.type;

  void Function(List<StoreEntity>)? get onSelectionChanged =>
      widget.onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final media0 = ref.watch(universalMediaProvider(type));
    if (media0.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PageManager.of(context).pop();
      });
      return const SizedBox.expand();
    }

    return CLEntitiesGridView(
      viewIdentifier: widget.viewIdentifier,
      incoming: media0.entries,
      filtersDisabled: true,
      whenEmpty: const WhenEmpty(),

      // Wizard don't use context menu
      contextMenuBuilder: (context, list) => EntityActions.empty(),
      onSelectionChanged: onSelectionChanged == null
          ? null
          : (items) => onSelectionChanged
              ?.call(items.map((e) => e as StoreEntity).toList()),
      itemBuilder: (context, item, entities) {
        if (item.isCollection) {
          return CollectionPreview.preview(
            item as StoreEntity,
            parentIdentifier: widget.viewIdentifier.parentID,
          );
        }
        return MediaThumbnail(
          parentIdentifier: widget.viewIdentifier.parentID,
          media: item as StoreEntity,
        );
      },
    );
  }
}
