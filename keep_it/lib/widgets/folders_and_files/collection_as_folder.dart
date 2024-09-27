import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../collection_editor.dart';

import '../wrap_standard_quick_menu.dart';

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
    return GetStoreUpdater(
      builder: (theStore) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onEdit: () async {
            final updated = await CollectionEditor.popupDialog(
              context,
              collection: collection,
            );
            if (updated != null && context.mounted) {
              await theStore.upsertCollection(updated);
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
              return theStore.deleteCollectionById(collection.id!);
            }
            return null;
          },
          onTap: () async {
            if (collection.id != null) {
              await Navigators.openCollection(context, collection.id!);
              return true;
            }
            return false;
          },
          child: Column(
            children: [
              Flexible(
                child: CollectionView.preview(collection),
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
      },
    );
  }
}
