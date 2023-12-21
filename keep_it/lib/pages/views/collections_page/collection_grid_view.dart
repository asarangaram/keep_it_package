import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../main/keep_it_main_view.dart';
import 'paginated_grid.dart';

class CollectionGridView extends ConsumerStatefulWidget {
  const CollectionGridView({
    super.key,
    required List<Collection> collections,

    // ignore: prefer_initializing_formals
  })  : collectionsNullable = collections,
        clusterID = null;
  const CollectionGridView.fromDB({
    super.key,
    this.clusterID,
  }) : collectionsNullable = null;

  final List<Collection>? collectionsNullable;
  final int? clusterID;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CollectionGridViewState();
}

class CollectionGridViewState extends ConsumerState<CollectionGridView> {
  bool isGridView = true;
  @override
  Widget build(BuildContext context) {
    return KeepItMainView(
      menuItems: [
        [
          CLMenuItem("New\nCollection", Icons.add),
          CLMenuItem("ListView", Icons.view_list)
        ]
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CLText.large(
                        "Collections",
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: switch (widget.collectionsNullable) {
                  null =>
                    CollectionGridFromDB(quickMenuScopeKey: quickMenuScopeKey),
                  _ => CollectionGrid(
                      quickMenuScopeKey: quickMenuScopeKey,
                      collectionList: widget.collectionsNullable!,
                    )
                },
              )
              // if (widget.collectionsNullable != null)
            ]);
      },
    );
  }
}

class CollectionGridFromDB extends ConsumerWidget {
  const CollectionGridFromDB({
    super.key,
    required this.quickMenuScopeKey,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));
    return collectionsAsync.when(
        loading: () => const CLLoadingView(),
        error: (err, _) => CLErrorView(errorMessage: err.toString()),
        data: (collections) {
          print("Loaded ${collections.entries.length} collections");
          return CollectionGrid(
              collectionList: collections.entries,
              quickMenuScopeKey: quickMenuScopeKey);
        });
  }
}

class CollectionGrid extends ConsumerWidget {
  const CollectionGrid({
    super.key,
    required this.quickMenuScopeKey,
    required this.collectionList,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<Collection> collectionList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionList.isEmpty) {
      return const Center(
        child: CLText.small(
          "No collections found",
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          // return Text("Loaded ${collectionList.length} collections");
          return PaginatedGrid(
            collections: collectionList,
            constraints: constraints,
            quickMenuScopeKey: quickMenuScopeKey,
          );
        },
      );
    }
  }
}

/*  */