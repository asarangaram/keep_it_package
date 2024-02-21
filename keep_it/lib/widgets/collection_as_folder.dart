import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import 'collection/upsert_collection_form.dart';
import 'wrap_standard_quick_menu.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.quickMenuScopeKey,
    super.key,
  });
  final Collection collection;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WrapStandardQuickMenu(
      quickMenuScopeKey: quickMenuScopeKey,
      onEdit: () async {
        final updated = await showDialog<Collection>(
          context: context,
          builder: (BuildContext context) {
            return CLDialogWrapper(
              onCancel: () => Navigator.of(context).pop(),
              child: CollectionEditor(
                collection: collection,
                onDone: (Collection updatedCollection) {
                  Navigator.of(context).pop(updatedCollection);
                },
              ),
            );
          },
        );
        if (updated != null) {
          await ref
              .read(collectionsProvider(null).notifier)
              .upsertCollection(updated, null);
          // ignore: unused_local_variable
          final items = ref.refresh(itemsProvider(collection.id!));
        }
        return true;
      },
      onDelete: () async {
        // delete all the items in the collection !!

        await ref
            .read(collectionsProvider(null).notifier)
            .deleteCollection(collection);
        return true;
      },
      onTap: () async {
        unawaited(
          context.push(
            '/items/${collection.id}',
          ),
        );
        return true;
      },
      child: Column(
        children: [
          Flexible(
            child: PreviewGenerator(
              collectionID: collection.id!,
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

class PreviewGenerator extends StatelessWidget {
  const PreviewGenerator({
    required this.collectionID,
    super.key,
  });
  final int collectionID;

  @override
  Widget build(BuildContext context) {
    return LoadItems(
      collectionID: collectionID,
      buildOnData: (Items items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            items.entries,
            hCount: 2,
            vCount: 2,
            itemBuilder: (context, index) => CLMediaPreview(
              media: items.entries[index],
              keepAspectRatio: false,
            ),
            whenNopreview: Center(
              child: CLText.veryLarge(
                items.collection.label.characters.first,
              ),
            ),
          ),
        );
      },
    );
  }
}
