import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLSelectionWrapper<T> extends StatefulWidget {
  const CLSelectionWrapper({
    required this.selectableList,
    required this.listBuilder,
    required this.onSelectionDone,
    super.key,
    this.multiSelection = false,
    this.labelSelected,
    this.labelNoneSelected,
  });
  final List<T> selectableList;
  final bool multiSelection;
  final String? labelSelected;
  final String? labelNoneSelected;
  final Widget Function({
    required List<T> selectableList,
    required void Function(int index) onSelection,
    required List<bool> selectionMask,
  }) listBuilder;
  final void Function(List<int> selectedIndex) onSelectionDone;

  @override
  State<StatefulWidget> createState() => CLSelectionWrapperState<T>();
}

class CLSelectionWrapperState<T> extends State<CLSelectionWrapper<T>> {
  late final List<bool> selectionMask;
  @override
  void initState() {
    selectionMask = widget.selectableList.map((e) => false).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = selectionMask.where((e) => e == true).toList().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 8),
          child: CLText.veryLarge(
            'Save Into ...',
            color: Theme.of(context).colorScheme.onTertiary,
          ),
        ),
        Expanded(
          child: widget.listBuilder(
            selectableList: widget.selectableList,
            onSelection: (index) {
              if (!widget.multiSelection) {
                widget.onSelectionDone([index]);
              }
              setState(() {
                selectionMask[index] = !selectionMask[index];
              });
            },
            selectionMask: selectionMask,
          ),
        ),
        const Divider(
          thickness: 2,
        ),
        const SizedBox(height: 16),
        if (selectedCount > 0) ...[
          CLText.small('$selectedCount selected'),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CLButtonText.veryLarge(
                widget.labelSelected ?? 'Done',
                boxDecoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                onTap: () {
                  widget.onSelectionDone(
                    selectionMask
                        .asMap()
                        .entries
                        .where((element) => element.value)
                        .map((e) => e.key)
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ] else ...[
          CLText.large(widget.labelNoneSelected ?? 'Select few'),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
