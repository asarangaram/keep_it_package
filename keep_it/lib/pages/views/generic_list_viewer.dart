// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLListItem {
  String title;
  String? subTitle;
  Widget? leading;
  CLListItem({
    required this.title,
    this.subTitle,
  });
}

class CLListView extends StatefulWidget {
  const CLListView({
    super.key,
    required this.items,
    this.onTab,
    required this.color,
    required this.disabledColor,
  })  : onSelectionDoneNullalbe = null,
        canSelectAll = false,
        saveLabelNullable = null;
  const CLListView.selectable(
      {super.key,
      required this.items,
      this.onTab,
      required this.color,
      required this.disabledColor,
      required Function(List<int> list) onSelectionDone,
      this.canSelectAll = true,
      String? saveLabel})
      : onSelectionDoneNullalbe = onSelectionDone,
        saveLabelNullable = saveLabel;
  final List<CLListItem> items;

  final Function(int index)? onTab;
  final Color color;
  final Color disabledColor;
  final void Function(List<int> list)? onSelectionDoneNullalbe;
  final bool canSelectAll;
  final String? saveLabelNullable;

  @override
  State<StatefulWidget> createState() => CLListViewState();
}

class CLListViewState extends State<CLListView> {
  late final List<bool>? selectionList;

  @override
  void initState() {
    if (widget.onSelectionDoneNullalbe != null) {
      selectionList = widget.items.map((e) => false).toList();
    } else {
      selectionList = null;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final canSelectAll = widget.canSelectAll && (selectionList != null);
    final items = widget.items;
    List<Widget>? leading = selectionList
        ?.asMap()
        .entries
        .map((e) => Checkbox(
            value: e.value,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectionList![e.key] = value;
                });
              }
            }))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length + (canSelectAll ? 1 : 0),
            itemBuilder: (context, i) {
              var index = i - ((selectionList != null) ? 1 : 0);

              if (canSelectAll && (i == 0)) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: CLText.standard(
                    selectionList!.every((element) => element == true)
                        ? "Select None"
                        : "Select All",
                    color: widget.color,
                  ),
                  leading: Checkbox(
                    value: selectionList!.every((element) => element == true),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          final val = !selectionList!
                              .every((element) => element == true);
                          for (var s = 0; s < selectionList!.length; s++) {
                            selectionList![s] = val;
                          }
                        });
                      }
                    },
                    activeColor:
                        selectionList!.every((element) => element == true)
                            ? null
                            : selectionList!.any((element) => element == true)
                                ? widget.disabledColor
                                : widget.color,
                  ),
                );
              }

              return ListTile(
                visualDensity: VisualDensity.compact,
                title: CLText.large(
                  items[index].title,
                  color: widget.color,
                ),
                subtitle: items[index].subTitle != null
                    ? CLText.small(
                        items[index].subTitle!,
                        color: widget.color,
                      )
                    : null,
                leading: leading?[index],
                onTap: () => widget.onTab?.call(index),
              );
            },
          ),
        ),
        if (widget.onSelectionDoneNullalbe != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 32),
            child: Center(
              child: CLButtonText.veryLarge(
                widget.saveLabelNullable ?? "Save",
                color: widget.color,
                disabledColor: widget.disabledColor,
                onTap: () => widget.onSelectionDoneNullalbe!.call(
                    List.generate(selectionList!.length, (index) => index)
                        .where((index) => selectionList![index])
                        .toList()),
              ),
            ),
          )
      ],
    );
  }
}

/* 
class GenericListView extends ConsumerWidget {
  const GenericListView({
    super.key,
    required this.collectionList,
    required this.onTab,
    required this.onSelectionDone,
    required this.onSelectionCancel,
    required this.isDialogView,
    // required this.theme,
  });
  final List collectionList;
  final Function(int index)? onTab;
  final void Function(List<dynamic>)? onSelectionDone;
  final void Function()? onSelectionCancel;
  final bool isDialogView;
  //final KeepItTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSelectable = onSelectionDone != null;
    final selectedItems =
        ref.watch(selectableItemsSelectedItemsProvider(collectionList));
    return ProviderScope(
      overrides: [
        selectableItemsSelectedItemsProvider.overrideWith((ref, items) {
          List cList = [];
          for (var c in items) {
            SelectableItem sc = ref.watch(selectableItemProvider(c));
            if (sc.isSelected) cList.add(sc.collection);
          }
          return cList;
        })
      ],
      child: CLDialogWrapper(
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
                onSave: () {
                  onSelectionDone?.call(selectedItems.map((e) => e).toList());
                  for (var c in selectedItems) {
                    ref.read(selectableItemProvider(c).notifier).deselect();
                  }
                },
                onDiscard: onSelectionCancel ?? () {},
                saveLabel: "Create Selected",
              )
            ]
          ],
        ),
      ),
    );
  }
}

class SelectableItem {
  final dynamic collection;
  final bool isSelected;

  SelectableItem({required this.collection, this.isSelected = false});

  SelectableItem copyWith({
    bool? isSelected,
  }) {
    return SelectableItem(
      collection: collection,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(covariant SelectableItem other) {
    if (identical(this, other)) return true;

    return other.collection == collection && other.isSelected == isSelected;
  }

  @override
  int get hashCode => collection.hashCode ^ isSelected.hashCode;

  SelectableItem toggleSelection() => copyWith(isSelected: !isSelected);
  SelectableItem select() => copyWith(isSelected: true);
  SelectableItem deselect() => copyWith(isSelected: false);
}

class SelectableItemNotifier extends StateNotifier<SelectableItem> {
  SelectableItemNotifier(super.selectableItem);

  toggleSelection() {
    state = state.toggleSelection();
  }

  select() {
    state = state.select();
  }

  deselect() {
    state = state.deselect();
  }
}

final selectableItemProvider = StateNotifierProvider.family<
    SelectableItemNotifier, SelectableItem, dynamic>((ref, item) {
  return SelectableItemNotifier(SelectableItem(collection: item));
});

final selectableItemsSelectedItemsProvider =
    StateProvider.family<List, List>((ref, item) {
  throw UnimplementedError();
});
 */