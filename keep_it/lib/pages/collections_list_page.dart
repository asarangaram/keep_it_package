import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_down_button/pull_down_button.dart';
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
          onUpload: (collection) {},
          onSync: (collection) {},
          onDeleteLocalCopy: (collection) {},
          onDeleteServerCopy: (collection) {},
          onDelete: (collection) {},
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
      final serverUID = pickRandom([true, false]) ? e + 0x10000 : null;
      return Collection.strict(
        id: e,
        label: 'collection $e',
        serverUID: serverUID,
        haveItOffline: pickRandom([true, false]),
        isDeleted: false,
        isEditted: false,
        description: null,
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
      onUpload: (collection) {
        collections = Collections(
          List.from(
            collections.entries.map((e) {
              if (e.id == collection.id) {
                // Upload and get serverID
                return e.copyWith(
                  serverUID: () => Random().nextInt(100000),
                  haveItOffline: true,
                );
              }
              return e;
            }),
          ),
        );
        setState(() {});
      },
      onSync: (collection) {
        collections = Collections(
          List.from(
            collections.entries.map((e) {
              if (e.id == collection.id) {
                // Upload and get serverID
                return e.copyWith(
                  haveItOffline: true,
                );
              }
              return e;
            }),
          ),
        );
        setState(() {});
      },
      onDeleteLocalCopy: (collection) {
        collections = Collections(
          List.from(
            collections.entries.map((e) {
              if (e.id == collection.id) {
                // Upload and get serverID
                return e.copyWith(
                  haveItOffline: false,
                );
              }
              return e;
            }),
          ),
        );
        setState(() {});
      },
      onDelete: (collection) {
        final entries = List<Collection>.from(collections.entries)
          ..removeWhere((e) => e.id == collection.id);
        collections = Collections(entries);
        setState(() {});
      },
      onDeleteServerCopy: (collection) {
        collections = Collections(
          List.from(
            collections.entries.map((e) {
              if (e.id == collection.id) {
                // Upload and get serverID
                return e.copyWith(
                  serverUID: () => null,
                  haveItOffline: false,
                );
              }
              return e;
            }),
          ),
        );
        setState(() {});
      },
    );
  }
}

class CollectionsList extends ConsumerStatefulWidget {
  const CollectionsList({
    required this.collections,
    required this.onUpload,
    required this.onSync,
    required this.onDeleteLocalCopy,
    required this.onDeleteServerCopy,
    required this.onDelete,
    super.key,
  });
  final Collections collections;
  final void Function(Collection collection) onUpload;
  final void Function(Collection collection) onSync;
  final void Function(Collection collection) onDeleteLocalCopy;
  final void Function(Collection collection) onDeleteServerCopy;
  final void Function(Collection collection) onDelete;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsListState();
}

class _CollectionsListState extends ConsumerState<CollectionsList> {
  bool? selection;

  @override
  Widget build(BuildContext context) {
    final List<Collection> collections;

    collections = switch (selection) {
      null => widget.collections.entries,
      true =>
        widget.collections.entries.where((e) => e.serverUID != null).toList(),
      false =>
        widget.collections.entries.where((e) => e.serverUID == null).toList()
    };

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SelectionFilter(
              currentSelection: selection,
              onSelectionChanged: ({selection}) {
                setState(() {
                  this.selection = selection;
                });
              },
            ),
          ),
        ],
      ),
      child: Column(
        children: [
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
                              child: PullDownButton(
                                itemBuilder: (context) => [
                                  PullDownMenuItem(
                                    title: 'Delete Server Copy',
                                    subtitle: 'Detach the device copy. '
                                        'Delete in server.',
                                    onTap: () =>
                                        widget.onDeleteServerCopy(collection),
                                  ),
                                  PullDownMenuItem(
                                    title: 'Delete',
                                    subtitle: 'delete everything, '
                                        'including device copy',
                                    icon: Icons.delete,
                                    onTap: () => widget.onDelete(collection),
                                  ),
                                ],
                                buttonBuilder: (context, showMenu) =>
                                    GestureDetector(
                                  onTap: showMenu,
                                  child: SizedBox.square(
                                    dimension: 24,
                                    child: Image.asset(
                                      'assets/icon/cloud_on_lan_128px_color.png',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: SizedBox.square(
                    dimension: 40,
                    child: switch (collection) {
                      (final Collection c) when collection.serverUID == null =>
                        FittedBox(
                          child: CLButtonIconLabelled.tiny(
                            Icons.upload,
                            'Upload',
                            onTap: () => widget.onUpload(c),
                          ),
                        ),
                      _ => FittedBox(
                          child: CLButtonIconLabelled.tiny(
                            collection.haveItOffline
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank,
                            'sync',
                            onTap: () {
                              if (collection.haveItOffline) {
                                widget.onDeleteLocalCopy(collection);
                              } else {
                                widget.onSync(collection);
                              }
                            },
                          ),
                        ),
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SelectionFilter extends ConsumerWidget {
  const SelectionFilter({
    required this.currentSelection,
    required this.onSelectionChanged,
    super.key,
  });
  final bool? currentSelection;
  final void Function({bool? selection}) onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<bool?>(
      child: Icon(clIcons.filter),
      itemBuilder: (context) {
        return [
          ...[null, true, false].map((e) {
            return PopupMenuItem<bool?>(
              value: e,
              onTap: () {
                onSelectionChanged(selection: e);
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.check,
                      color: (e == currentSelection)
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ),
                  Text(
                    switch (e) {
                      null => 'All',
                      true => 'Server Collections',
                      false => 'Device Collections'
                    },
                  ),
                ],
              ),
            );
          }),
        ];
      },
    );
  }
}
