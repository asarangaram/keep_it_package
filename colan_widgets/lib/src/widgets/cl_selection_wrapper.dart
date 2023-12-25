import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';


class CLSelectionWrapper extends StatefulWidget {
  const CLSelectionWrapper(
      {super.key,
      required this.selectableList,
      required this.listBuilder,
      required this.onSelectionDone,
      this.multiSelection = false});
  final List selectableList;
  final bool multiSelection;
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
        if (selectedCount > 0) ...[
          const SizedBox(
            height: 16,
          ),
          CLText.small("$selectedCount selected"),
          CLButtonText.veryLarge(
            "Done",
            onTap: () {
              widget.onSelectionDone(selectionMask
                  .asMap()
                  .entries
                  .where((element) => element.value)
                  .map((e) => e.key)
                  .toList());
            },
          ),
          const SizedBox(
            height: 16,
          ),
        ] else ...[
          const SizedBox(height: 16),
          const CLText.large("Select from Suggestions"),
          const SizedBox(height: 16)
        ]
      ],
    );
  }
}
