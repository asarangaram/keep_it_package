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
                  await theStore.collectionUpdater.upsert(
                    collection.copyWith(serverUID: () => -1, isEdited: true),
                  );
                  ref.read(serverProvider.notifier).instantSync();

                  return true;
                },
                onKeepOffline: () async {
                  if (!collection.haveItOffline && collection.hasServerUID) {
                    final serverNotifier = ref.read(serverProvider.notifier);
                    final updater = await serverNotifier.storeUpdater;

                    await updater.collectionUpdater
                        .upsert(collection.copyWith(haveItOffline: true));
                    final media = await updater.store.reader
                        .getMediaByCollectionId(collection.id!);
                    for (final m in media) {
                      await updater.mediaUpdater.update(
                        m,
                        haveItOffline: () => null,
                        isEdited: false,
                      );
                    }
                    updater.store.reloadStore();
                    serverNotifier.instantSync();
                  }
                  return true;
                },
                onDeleteLocalCopy: () async {
                  if (collection.haveItOffline && collection.hasServerUID) {
                    final serverNotifier = ref.read(serverProvider.notifier);
                    final updater = await serverNotifier.storeUpdater;

                    await updater.collectionUpdater
                        .upsert(collection.copyWith(haveItOffline: false));
                    final media = await updater.store.reader
                        .getMediaByCollectionId(collection.id!);
                    for (final m in media) {
                      await theStore.mediaUpdater
                          .deleteLocalCopy(m, haveItOffline: () => null);
                    }
                    serverNotifier.instantSync();
                  }
                  return true;
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      child: Text(
                        collection.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox.square(
                    dimension: 20,
                    child: Image.asset(
                      (collection.serverUID == null)
                          ? 'assets/icon/not_on_server.png'
                          : 'assets/icon/cloud_on_lan_128px_color.png',
                    ),
                  ),
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
      await theStore.collectionUpdater.update(updated, isEdited: true);
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
