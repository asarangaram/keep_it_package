import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../collection_editor.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.onTap,
    super.key,
  });
  final Collection collection;
  final void Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
        // ignore: dead_code
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        return Column(
          children: [
            Flexible(
              child: CollectionMenu(
                collection: collection,
                isSyncing: false,
                child: CollectionView.preview(collection),
                onTap: () async {
                  onTap();
                  return true;
                },
                onEdit: () async => onEdit(context, ref, theStore),
                onDelete: () async => onDelete(context, ref, theStore),
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
            Row(
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
          ],
        );
      },
    );
  }

  Future<bool> onEdit(
    BuildContext context,
    WidgetRef ref,
    StoreUpdater theStore,
  ) async {
    final updated = await CollectionEditor.popupDialog(
      context,
      ref,
      collection: collection,
    );
    if (updated != null && context.mounted) {
      await theStore.collectionUpdater.update(updated, isEdited: true);
    }

    return true;
  }

  Future<bool> onDelete(
    BuildContext context,
    WidgetRef ref,
    StoreUpdater theStore,
  ) async {
    final confirmed = await ConfirmAction.deleteCollection(
          context,
          ref,
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
