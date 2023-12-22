import 'package:flutter/material.dart';

import '../basics/cl_button.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
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
        )
      ],
    );
  }
}
