import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLSelectionWrapper extends StatefulWidget {
  const CLSelectionWrapper({
    super.key,
    required this.selectableList,
    required this.listBuilder,
    required this.onSelectionDone,
    this.multiSelection = false,
    this.labelSelected,
    this.labelNoneSelected,
  });
  final List selectableList;
  final bool multiSelection;
  final String? labelSelected;
  final String? labelNoneSelected;
  final Widget Function(
      {required List selectableList,
      required Function(int index) onSelection,
      required List<bool> selectionMask}) listBuilder;
  final Function(List<int> selectedIndex) onSelectionDone;

  @override
  State<StatefulWidget> createState() => CLSelectionWrapperState();
}

class CLSelectionWrapperState extends State<CLSelectionWrapper> {
  late final List<bool> selectionMask;
  @override
  void initState() {
    selectionMask = widget.selectableList.map((e) => false).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.labelNoneSelected);
    print(widget.labelSelected);
    final selectedCount = selectionMask.where((e) => e == true).toList().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              selectionMask: selectionMask),
        ),
        const Divider(
          thickness: 2,
        ),
        const SizedBox(height: 16),
        if (selectedCount > 0) ...[
          CLText.small("$selectedCount selected"),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CLButtonText.veryLarge(
                widget.labelSelected ?? "Done",
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
                  widget.onSelectionDone(selectionMask
                      .asMap()
                      .entries
                      .where((element) => element.value)
                      .map((e) => e.key)
                      .toList());
                },
              ),
            ),
          ),
        ] else ...[
          CLText.large(widget.labelNoneSelected ?? "Select few"),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
