import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../collection_editor.dart';

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
        return Column(
          children: [
            Flexible(
              child: CollectionMenu(
                collection: collection,
                isSyncing: false,
                child: CollectionView.preview(collection),
                onTap: () async => onTap(context),
                onEdit: () async => onEdit(context, theStore),
                onDelete: () async => onDelete(context, theStore),
                onUpload: () async {
                  final serverNotifier = ref.read(serverProvider.notifier);
                  final collectionSyncModule =
                      await serverNotifier.collectionSyncModule;
                  await collectionSyncModule.upload(collection);
                  serverNotifier.sync();
                  return true;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 16, top: 2, bottom: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        collection.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (collection.serverUID == null)
                    SizedBox.square(
                      dimension: 24,
                      child: Image.asset('assets/icon/on_device.png'),
                    )
                  else
                    SizedBox.square(
                      dimension: 24,
                      child: Image.asset(
                        'assets/icon/cloud_on_lan_128px_color.png',
                      ),
                    ),
                  /* if (collection.serverUID != null)
                    Image.asset(
                      'assets/icon/cloud_on_lan_128px_color.png',
                    ), */
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> onTap(BuildContext context) async {
    await Navigators.openCollection(context, collection.id!);
    return true;
  }

  Future<bool> onEdit(BuildContext context, StoreUpdater theStore) async {
    final updated = await CollectionEditor.popupDialog(
      context,
      collection: collection,
    );
    if (updated != null && context.mounted) {
      await theStore.collectionUpdater.upsert(updated);
    }

    return true;
  }

  Future<bool> onDelete(BuildContext context, StoreUpdater theStore) async {
    final confirmed = await ConfirmAction.deleteCollection(
          context,
          collection: collection,
        ) ??
        false;
    if (!confirmed) return confirmed;
    if (context.mounted) {
      return theStore.collectionUpdater.delete(collection.id!);
    }
    return false;
  }
}
