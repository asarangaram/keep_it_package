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
        return CollectionsList(collections: collections);
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
    (e) => Collection(
      label: 'collection $e',
      collectionStoragePreference:
          pickRandom(CollectionStoragePreference.values),
    ),
  ),
]);

class CollectionsListDemo extends ConsumerStatefulWidget {
  const CollectionsListDemo({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsListDemoState();
}

class _CollectionsListDemoState extends ConsumerState<CollectionsListDemo> {
  late final Collections collections;
  @override
  void initState() {
    collections = Collections(List.from(demoCollections.entries));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CollectionsList(
      collections: collections,
    );
  }
}

class CollectionsList extends ConsumerStatefulWidget {
  const CollectionsList({required this.collections, super.key});
  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsListState();
}

class _CollectionsListState extends ConsumerState<CollectionsList> {
  @override
  Widget build(BuildContext context) {
    final collectionStoragePreference =
        ref.watch(collectionStoragePreferenceProvider);
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
                  CollectionStoragePreference.onlineOnly =>
                    'These collections are only available online. '
                        'You can view only when you are connected to server.',
                  CollectionStoragePreference.offlineOnly =>
                    'These collections are only available on your device. '
                        'Sync them to keep-it on your CoLAN server',
                  CollectionStoragePreference.synced =>
                    'These collections are synced. '
                        'removing them from local will save your space, '
                        "but won't be available when "
                        'you are not connected to the server',
                },
                color: Colors.white,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return CheckboxListTile(
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: collection.label),
                        if (collection.collectionStoragePreference !=
                            CollectionStoragePreference.offlineOnly)
                          WidgetSpan(
                            child: Transform.translate(
                              offset: const Offset(0, -10),
                              child: SizedBox.square(
                                dimension: 24,
                                child: Image.asset(
                                  'assets/icon/cloud_on_lan_128px_color.png',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  value: collection.collectionStoragePreference ==
                      CollectionStoragePreference.synced,
                  onChanged: (val) {},
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
        ref.watch(collectionStoragePreferenceProvider);

    return PopupMenuButton<CollectionStoragePreference?>(
      child: Icon(clIcons.filter),
      itemBuilder: (context) {
        return [
          ...[null, ...CollectionStoragePreference.values].map((e) {
            return PopupMenuItem<CollectionStoragePreference?>(
              value: e,
              onTap: () {
                ref.read(collectionStoragePreferenceProvider.notifier).state =
                    e;
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

final collectionStoragePreferenceProvider =
    StateProvider<CollectionStoragePreference?>((ref) {
  return null;
});
