import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CollectionsStoragePreferences extends ConsumerWidget {
  const CollectionsStoragePreferences({super.key, this.isDemo = true});
  final bool isDemo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isDemo) {
      return const CollectionsListDemo();
    }
    return GetCollectionMultiple(
      errorBuilder: (e, st) => FullscreenLayout(
        child: BasicPageService.withNavBar(
          message: e.toString(),
        ),
      ),
      loadingBuilder: () => FullscreenLayout(
        child: BasicPageService.withNavBar(message: const CLLoadingView()),
      ),
      excludeEmpty: false,
      builder: (collections) {
        return CollectionsList(
          collections: collections,
          onSync: (id, serverUID) async {},
          onCancelSync: (id) async {},
          onRemoveLocalCopy: (id, serverUID) async {},
          onRemoveServerCopy: (id, serverUID) async {},
        );
      },
    );
  }
}

T pickRandom<T>(List<T> list) {
  final random = Random();
  final index = random.nextInt(list.length);
  return list[index];
}

Collections demoCollections = Collections([
  ...List.generate(
    100,
    (e) {
      final CollectionStoragePreference storagePreference = pickRandom([
        CollectionStoragePreference.notSynced,
        CollectionStoragePreference.synced,
        CollectionStoragePreference.syncing,
      ]);
      //storagePreference = CollectionStoragePreference.notSynced;
      final int? serverUID;
      if (storagePreference.isSynced) {
        serverUID = e + 0x10000;
      } else {
        serverUID = pickRandom([true, false]) ? e + 0x10000 : null;
      }

      return Collection(
        id: e,
        label: 'collection $e',
        serverUID: serverUID,
        collectionStoragePreference: storagePreference,
      );
    },
  ),
]);

class CollectionsListDemo extends ConsumerStatefulWidget {
  const CollectionsListDemo({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsListDemoState();
}

class _CollectionsListDemoState extends ConsumerState<CollectionsListDemo> {
  late Collections collections;
  @override
  void initState() {
    collections = Collections(List.from(demoCollections.entries));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CollectionsList(
      collections: collections,
      onSync: (collectionID, serverUID) async {
        collections =
            collections.markForSyncing(collectionID, serverUID: serverUID);
        setState(() {});
        // Perform  Sync
        await Future<void>.delayed(const Duration(seconds: 2));
        collections = collections.markAsSynced(collectionID);
        setState(() {});
      },
      onCancelSync: (collectionID) async {
        collections = collections.revertSyncing(collectionID);
        setState(() {});
      },
      onRemoveLocalCopy: (collectionID, serverUID) async {
        collections =
            collections.markForSyncing(collectionID, serverUID: serverUID);
        setState(() {});
        // remove Local copy
        await Future<void>.delayed(const Duration(seconds: 2));

        collections = collections.removeLocalCopy(collectionID);
        setState(() {});
      },
      onRemoveServerCopy: (collectionID, serverUID) async {
        collections =
            collections.markForSyncing(collectionID, serverUID: serverUID);
        setState(() {});
        // remove Local copy
        await Future<void>.delayed(const Duration(seconds: 2));
        collections = collections.removeServerCopy(collectionID);
        setState(() {});
      },
    );
  }
}

class CollectionsList extends ConsumerStatefulWidget {
  const CollectionsList({
    required this.collections,
    required this.onSync,
    required this.onCancelSync,
    required this.onRemoveLocalCopy,
    required this.onRemoveServerCopy,
    super.key,
  });
  final Collections collections;
  final Future<void> Function(int collectionId, int serverUID) onSync;
  final Future<void> Function(int collectionId) onCancelSync;
  final Future<void> Function(int collectionId, int serverUID)
      onRemoveLocalCopy;
  final Future<void> Function(int collectionId, int serverUID)
      onRemoveServerCopy;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsListState();
}

class _CollectionsListState extends ConsumerState<CollectionsList> {
  @override
  Widget build(BuildContext context) {
    final collectionStoragePreference =
        ref.watch(collectionStoragePreferenceFilterProvider);
    final List<Collection> collections;
    if (collectionStoragePreference == null) {
      collections = widget.collections.entries;
    } else {
      collections = widget.collections.entries
          .where(
            (e) => e.collectionStoragePreference == collectionStoragePreference,
          )
          .toList();
    }

    return FullscreenLayout(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Collections'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: CLPopScreen.onTap(
          child: CLButtonIcon.small(
            clIcons.pagePop,
            onTap: () => CLPopScreen.onPop(context),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CollectionStoragePreferenceFilter(),
          ),
        ],
      ),
      child: Column(
        children: [
          if (collectionStoragePreference != null)
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade600),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CLText.tiny(
                switch (collectionStoragePreference) {
                  CollectionStoragePreference.notSynced =>
                    'These collections are only available online or local. '
                        'If online, You can view only when you are connected '
                        'to server. '
                        'Sync them to keep-it on your CoLAN server and local ',
                  CollectionStoragePreference.synced =>
                    'These collections are synced. '
                        'removing them from local will save your space, '
                        "but won't be available when "
                        'you are not connected to the server',
                  CollectionStoragePreference.syncing =>
                    'These collections are syncing. You may abort syncing'
                },
                color: Colors.white,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return ListTile(
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: collection.label),
                        if (collection.serverUID != null)
                          WidgetSpan(
                            child: Transform.translate(
                              offset: const Offset(0, -10),
                              child: PopupMenuButton<int>(
                                child: SizedBox.square(
                                  dimension: 24,
                                  child: Image.asset(
                                    'assets/icon/cloud_on_lan_128px_color.png',
                                  ),
                                ),
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem<int>(
                                      value: 1,
                                      child: const Text('Delete Server Copy'),
                                      onTap: () {
                                        showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return const AlertDialog(
                                              title: Text('Coming Soon'),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ];
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: switch (collection.collectionStoragePreference) {
                    CollectionStoragePreference.notSynced =>
                      CLButtonIcon.standard(
                        collection.serverUID == null
                            ? Icons.file_upload
                            : Icons.check_box_outline_blank,
                        onTap: () {
                          if (collection.serverUID != null &&
                              collection.id != null) {
                            widget.onSync(
                              collection.id!,
                              collection.serverUID!,
                            );
                          }
                          if (collection.serverUID == null) {
                            const serverUID = 100; // Create ServerUID
                            widget.onSync(
                              collection.id!,
                              serverUID,
                            );
                          }
                        },
                      ),
                    CollectionStoragePreference.syncing =>
                      const CircularProgressIndicator(),
                    CollectionStoragePreference.synced => CLButtonIcon.standard(
                        Icons.check_box_outlined,
                        onTap: () {
                          if (collection.serverUID != null &&
                              collection.id != null) {
                            widget.onRemoveLocalCopy(
                              collection.id!,
                              collection.serverUID!,
                            );
                          }
                        },
                      ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionStoragePreferenceFilter extends ConsumerWidget {
  const CollectionStoragePreferenceFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionStoragePreference =
        ref.watch(collectionStoragePreferenceFilterProvider);

    return PopupMenuButton<CollectionStoragePreference?>(
      child: Icon(clIcons.filter),
      itemBuilder: (context) {
        return [
          ...[null, ...CollectionStoragePreference.values].map((e) {
            return PopupMenuItem<CollectionStoragePreference?>(
              value: e,
              onTap: () {
                ref
                    .read(collectionStoragePreferenceFilterProvider.notifier)
                    .state = e;
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.check,
                      color: (e == collectionStoragePreference)
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ),
                  Text(e?.name ?? 'All'),
                ],
              ),
            );
          }),
        ];
      },
    );
  }
}

final collectionStoragePreferenceFilterProvider =
    StateProvider<CollectionStoragePreference?>((ref) {
  return null;
});
