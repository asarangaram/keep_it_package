import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/collection.dart';
import '../../providers/db_store.dart';
import '../../providers/select_handler.dart';
import '../../providers/theme.dart';
import 'receive_shared/save_or_cancel.dart';

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
      return _CollectionListViewImpl(
        isDialogView: true,
        collectionList: collectionListNullable!,
        onTab: onTabItemNullable,
        onSelectionDone: onSelectionDoneNullable,
        onSelectionCancel: onSelectionCancelNullable,
      );
    }

    final collectionsAsync = ref.watch(collectionsProvider(null));
    return collectionsAsync.when(
      loading: () =>
          const CLDialogWrapper(isDialog: true, child: CLLoadingView()),
      error: (err, _) => CLDialogWrapper(
        isDialog: true,
        child: CLErrorView(
          errorMessage: err.toString(),
        ),
      ),
      data: (collections) => _CollectionListViewImpl(
        isDialogView: true,
        collectionList: collections.collections,
        onTab: onTabItemNullable,
        onSelectionDone: onSelectionDoneNullable,
        onSelectionCancel: onSelectionCancelNullable,
      ),
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

class _CollectionListViewImpl extends ConsumerWidget {
  const _CollectionListViewImpl({
    required this.collectionList,
    required this.onTab,
    required this.onSelectionDone,
    required this.onSelectionCancel,
    required this.isDialogView,
  });
  final List<Collection> collectionList;
  final Function(int index)? onTab;
  final void Function(List<Collection>)? onSelectionDone;
  final void Function()? onSelectionCancel;
  final bool isDialogView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSelectable = onSelectionDone != null;
    final theme = ref.watch(themeProvider);
    final selectedItems =
        ref.watch(selectableItemsSelectedItemsProvider(collectionList));
    return CLDialogWrapper(
      isDialog: isDialogView,
      child: Column(
        children: [
          if (isSelectable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CLButtonText.standard(
                  "Select All",
                  color: theme.colorTheme.buttonText,
                  disabledColor: theme.colorTheme.disabledColor,
                  onTap: () {
                    for (var c in collectionList) {
                      ref.read(selectableItemProvider(c).notifier).select();
                    }
                  },
                ),
                CLButtonText.standard(
                  "Select None",
                  color: theme.colorTheme.buttonText,
                  disabledColor: theme.colorTheme.disabledColor,
                  onTap: () {
                    for (var c in collectionList) {
                      ref.read(selectableItemProvider(c).notifier).deselect();
                    }
                  },
                )
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: collectionList.length,
              itemBuilder: (context, index) {
                final selectableItem =
                    ref.watch(selectableItemProvider(collectionList[index]));
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(collectionList[index].label),
                  subtitle: (collectionList[index].description != null)
                      ? Text(collectionList[index].description!)
                      : null,
                  leading: (isSelectable)
                      ? Checkbox(
                          value: selectableItem.isSelected,
                          onChanged: (value) {
                            // Update the isChecked property when the checkbox is toggled
                            if (value != null) {
                              ref
                                  .read(selectableItemProvider(
                                          collectionList[index])
                                      .notifier)
                                  .toggleSelection();
                            }
                          },
                        )
                      : null,
                  onTap: () => onTab?.call(index),
                );
              },
            ),
          ),
          if (isSelectable) ...[
            const Divider(
              thickness: 4,
              height: 4,
            ),
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: selectedItems.map((e) => e.label).join(", "),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: CLScaleType.small.fontSize))
                  ])),
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              height: 4,
            ),
            SaveOrCancel(
              onSave: () => onSelectionDone
                  ?.call(selectedItems.map((e) => e as Collection).toList()),
              onDiscard: onSelectionCancel ?? () {},
              saveLabel: "Create Selected",
            )
          ]
        ],
      ),
    );
  }
}
