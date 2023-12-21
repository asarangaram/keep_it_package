import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/main/main_header.dart';
import 'package:store/store.dart';

import '../main/keep_it_main_view.dart';
import 'add_collection_form.dart';
import 'paginated_grid.dart';

class CollectionsView extends ConsumerStatefulWidget {
  const CollectionsView(this.collections, {super.key});
  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CollectionsViewState();
}

class CollectionsViewState extends ConsumerState<CollectionsView> {
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
    return KeepItMainView(
      title: widget.collections.isNotEmpty ? "Collections" : null,
      actionsBuilder: [
        (context, quickMenuScopeKey) {
          return CLQuickMenuAnchor(
            parentKey: quickMenuScopeKey,
            menuBuilder: (context, boxconstraints,
                {required Function() onDone}) {
              return CLButtonsGrid(
                scaleType: CLScaleType.veryLarge,
                size: const Size(kMinInteractiveDimension * 1.5,
                    kMinInteractiveDimension * 1.5),
                children2D: MainHeader.insertOnDone(
                    context,
                    [
                      [
                        CLMenuItem("Suggested\nCollections", Icons.menu),
                        CLMenuItem("Create New", Icons.new_label,
                            onTap: () => newCollectionForm(onDone: onDone))
                      ]
                    ],
                    onDone),
              );
            },
            child: const CLIcon.veryLarge(
              Icons.add,
            ),
          );
        },
        (context, quickMenuScopeKey) => const CLButtonIcon.veryLarge(
              Icons.view_list,
            )
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        if (widget.collections.isEmpty) {}
        return CollectionGrid(
          quickMenuScopeKey: quickMenuScopeKey,
          collectionList: widget.collections.entries,
        );
      },
    );
  }

  void newCollectionForm({Function()? onDone}) => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CLDialogWrapper(onCancel: () {
            Navigator.of(context).pop();
          }, child: UpsertCollectionDialogForm(
            onDone: () {
              onDone?.call();
              Navigator.of(context).pop();
            },
          ));
        },
      );
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
