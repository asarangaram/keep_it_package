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
    required this.items,
    super.key,
    this.onTab,
    this.color,
    this.disabledColor,
  })  : onSelectionDoneNullalbe = null,
        canSelectAll = false,
        saveLabelNullable = null;
  const CLListView.selectable({
    required this.items,
    required void Function(List<int> list) onSelectionDone,
    super.key,
    this.onTab,
    this.color,
    this.disabledColor,
    this.canSelectAll = true,
    String? saveLabel,
  })  : onSelectionDoneNullalbe = onSelectionDone,
        saveLabelNullable = saveLabel;
  final List<CLListItem> items;

  final void Function(int index)? onTab;
  final Color? color;
  final Color? disabledColor;
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
    final List<Widget>? leading = selectionList
        ?.asMap()
        .entries
        .map(
          (e) => Checkbox(
            value: e.value,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectionList![e.key] = value;
                });
              }
            },
          ),
        )
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length + (canSelectAll ? 1 : 0),
            itemBuilder: (context, i) {
              final index = i - ((selectionList != null) ? 1 : 0);

              if (canSelectAll && (i == 0)) {
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: CLText.standard(
                    selectionList!.every((element) => element == true)
                        ? 'Select None'
                        : 'Select All',
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
                ),
                subtitle: items[index].subTitle != null
                    ? CLText.small(
                        items[index].subTitle!,
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
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: Center(
              child: CLButtonText.veryLarge(
                widget.saveLabelNullable ?? 'Save',
                onTap: () => widget.onSelectionDoneNullalbe!.call(
                  List.generate(selectionList!.length, (index) => index)
                      .where((index) => selectionList![index])
                      .toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
