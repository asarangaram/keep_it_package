/* import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../generic_list_viewer.dart';

class CollectionListView extends ConsumerWidget {
  const CollectionListView({
    super.key,
    required this.collectionListNullable,
    required this.onTabItemNullable,
    required this.onSelectionDoneNullable,
    required this.onSelectionCancelNullable,
    required this.isDialogView,
    required this.clusterID,
    required this.fromDB,
  });

  const CollectionListView.fromList({
    super.key,
    required List<Collection> collectionList,
    required Function(int index) onTabItem,
  })  : collectionListNullable = collectionList,
        onTabItemNullable = onTabItem,
        isDialogView = false,
        onSelectionDoneNullable = null,
        onSelectionCancelNullable = null,
        clusterID = null,
        fromDB = false;
  const CollectionListView.fromDB({
    super.key,
    required this.clusterID,
    required Function(int index) onTabItem,
  })  : collectionListNullable = null,
        onTabItemNullable = onTabItem,
        isDialogView = false,
        onSelectionDoneNullable = null,
        onSelectionCancelNullable = null,
        fromDB = true;

  const CollectionListView.fromListSelectable({
    super.key,
    required List<Collection> collectionList,
    required Function(List<Collection>)? onSelectionDone,
    required bool Function()? onSelectionCancel,
  })  : collectionListNullable = collectionList,
        onSelectionDoneNullable = onSelectionDone,
        onSelectionCancelNullable = onSelectionCancel,
        onTabItemNullable = null,
        isDialogView = false,
        clusterID = null,
        fromDB = false;
  const CollectionListView.fromDBSelectable({
    super.key,
    required this.clusterID,
    required void Function(List<Collection>)? onSelectionDone,
    required void Function()? onSelectionCancel,
  })  : collectionListNullable = null,
        onSelectionDoneNullable = onSelectionDone,
        onSelectionCancelNullable = onSelectionCancel,
        onTabItemNullable = null,
        isDialogView = false,
        fromDB = true;

  final List<Collection>? collectionListNullable;
  final Function(int index)? onTabItemNullable;
  final void Function(List<Collection>)? onSelectionDoneNullable;
  final void Function()? onSelectionCancelNullable;
  final bool isDialogView;
  final int? clusterID;
  final bool fromDB;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!fromDB) {
      if (collectionListNullable == null) {
        throw "Implementation Error";
      }
      return Center(
        child: CLDialogWrapper(
          isDialog: isDialogView,
          padding: EdgeInsets.zero,
          child: switch (onSelectionDoneNullable) {
            null => CLListView(
                items: collectionListNullable!
                    .map((e) => CLListItem(
                          title: e.label,
                          subTitle: e.description,
                        ))
                    .toList(),
              ),
            _ => CLListView.selectable(
                items: collectionListNullable!
                    .map((e) => CLListItem(
                          title: e.label,
                          subTitle: e.description,
                        ))
                    .toList(),
                onSelectionDone: (l) {
                  onSelectionDoneNullable
                      ?.call(l.map((e) => collectionListNullable![e]).toList());
                },
              )
          },
        ),
      );
    }

    final collectionsAsync = ref.watch(collectionsProvider(null));
    return collectionsAsync.when(
      loading: () =>
          CLDialogWrapper(isDialog: isDialogView, child: const CLLoadingView()),
      error: (err, _) => CLDialogWrapper(
        isDialog: isDialogView,
        child: CLErrorView(
          errorMessage: err.toString(),
        ),
      ),
      data: (collections) => CLDialogWrapper(
          isDialog: isDialogView,
          child: switch (onSelectionDoneNullable) {
            null => CLListView(
                items: collections.entries
                    .map((e) => CLListItem(
                          title: e.label,
                          subTitle: e.description,
                        ))
                    .toList(),
              ),
            _ => CLListView.selectable(
                items: collections.entries
                    .map((e) => CLListItem(
                          title: e.label,
                          subTitle: e.description,
                        ))
                    .toList(),
                onSelectionDone: (l) {
                  onSelectionDoneNullable
                      ?.call(l.map((e) => collections.entries[e]).toList());
                },
              ),
          }),
    );
  }
}

class CollectionListViewDialog extends CollectionListView {
  const CollectionListViewDialog.fromList({
    super.key,
    required List<Collection> collectionList,
    required Function(int index) onTabItem,
  }) : super(
            collectionListNullable: collectionList,
            onTabItemNullable: onTabItem,
            isDialogView: false,
            onSelectionDoneNullable: null,
            onSelectionCancelNullable: null,
            clusterID: null,
            fromDB: false);
  const CollectionListViewDialog.fromDB({
    super.key,
    required super.clusterID,
    required Function(int index) onTabItem,
  }) : super(
            collectionListNullable: null,
            onTabItemNullable: onTabItem,
            isDialogView: false,
            onSelectionDoneNullable: null,
            onSelectionCancelNullable: null,
            fromDB: true);

  const CollectionListViewDialog.fromListSelectable({
    super.key,
    required List<Collection> collectionList,
    required Function(List<Collection>)? onSelectionDone,
    required bool Function()? onSelectionCancel,
  }) : super(
            collectionListNullable: collectionList,
            onSelectionDoneNullable: onSelectionDone,
            onSelectionCancelNullable: onSelectionCancel,
            onTabItemNullable: null,
            isDialogView: false,
            clusterID: null,
            fromDB: false);
  const CollectionListViewDialog.fromDBSelectable({
    super.key,
    required super.clusterID,
    required void Function(List<Collection>)? onSelectionDone,
    required void Function()? onSelectionCancel,
  }) : super(
            collectionListNullable: null,
            onSelectionDoneNullable: onSelectionDone,
            onSelectionCancelNullable: onSelectionCancel,
            onTabItemNullable: null,
            isDialogView: false,
            fromDB: true);
}
 */
