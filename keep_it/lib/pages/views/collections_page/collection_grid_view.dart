import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../main/keep_it_main_view.dart';
import 'add_collection_form.dart';
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

  newCollectionForm({Function()? onDone}) => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(onCancel: () {
            Navigator.of(context).pop();
          }, child: UpsertCollectionDialogForm(
            onDone: () {
              Navigator.of(context).pop();
              onDone?.call();
            },
          ));
        },
      );

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionsProvider(null));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: (collections) {
        return KeepItMainView(
          actions: [
            CLButtonIcon.large(
              Icons.add,
              onTap: () {},
            ),
            CLButtonIcon.large(
              Icons.view_list,
              onTap: () {},
            )
          ],
          menuItems: const [],
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
                      null => CollectionGridFromDB(
                          quickMenuScopeKey: quickMenuScopeKey),
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
      },
    );
  }

  onCreateNewCollection(Function({Function()? onDone}) handleCreateNew) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CLButtonsGrid.dialog(
            onCancel: () {
              Navigator.of(context).pop();
            },
            children2D: [
              [
                CLMenuItem("Suggested\nCollections", Icons.menu),
                CLMenuItem("Create New", Icons.new_label, onTap: () {
                  newCollectionForm(onDone: () {
                    Navigator.of(context).pop();
                  });
                }),
              ],
            ],
          );
        },
      );
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
    final collectionsAsync = ref.watch(collectionsProvider(null));
    final handleCreateNew = collectionsAsync.whenOrNull(
        data: (collections) => ({Function()? onDone}) => showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return CLDialogWrapper(onCancel: () {
                  Navigator.of(context).pop();
                }, child: UpsertCollectionDialogForm(
                  onDone: () {
                    Navigator.of(context).pop();
                    onDone?.call();
                  },
                ));
              },
            ));
    if (collectionList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CLText.large(
              "Create your first collection",
            ),
            const SizedBox(
              height: 32,
            ),
            CLButtonsGrid(
              children2D: [
                [
                  CLMenuItem("Suggested\nCollections", Icons.menu),
                  CLMenuItem("Create New", Icons.new_label, onTap: () {
                    handleCreateNew?.call(onDone: () {});
                  }),
                ]
              ],
            )
          ],
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
} /*  */
