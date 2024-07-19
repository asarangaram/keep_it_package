import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../collection_editor.dart';

import '../wrap_standard_quick_menu.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.quickMenuScopeKey,
    required this.getPreview,
    super.key,
  });
  final Collection collection;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Widget Function(CLMedia media) getPreview;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WrapStandardQuickMenu(
      quickMenuScopeKey: quickMenuScopeKey,
      onEdit: () async {
        final updated = await CollectionEditor.popupDialog(
          context,
          collection: collection,
        );
        if (updated != null && context.mounted) {
          await TheStore.of(context).upsertCollection(updated);
        }

        return true;
      },
      onDelete: () async {
        final confirmed = await ConfirmAction.deleteCollection(
              context,
              collection: collection,
            ) ??
            false;
        if (!confirmed) return confirmed;
        if (context.mounted) {
          return TheStore.of(context).deleteCollection(context, collection);
        }
        return null;
      },
      onTap: () async {
        await TheStore.of(context)
            .openCollection(context, collectionId: collection.id);
        return true;
      },
      child: Column(
        children: [
          Flexible(
            child: CollectionPreviewGenerator(
              collection: collection,
              getPreview: getPreview,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              collection.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionPreviewGenerator extends StatelessWidget {
  const CollectionPreviewGenerator({
    required this.collection,
    required this.getPreview,
    super.key,
  });
  final Collection collection;
  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context) {
    return GetMediaByCollectionId(
      collectionId: collection.id,
      buildOnData: (items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            items,
            hCount: 2,
            vCount: 2,
            itemBuilder: (context, index) => getPreview(
              items[index],
            ),
            whenNopreview: Center(
              child: CLText.veryLarge(
                collection.label.characters.first,
              ),
            ),
          ),
        );
      },
    );
  }
}
