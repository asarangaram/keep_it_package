import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class SelectionCount extends StatelessWidget {
  const SelectionCount(this.selectionMap, {super.key, this.onSelectAll});
  final List<GalleryGroupMutable<bool>> selectionMap;
  final void Function({required bool select})? onSelectAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          //color: Theme.of(context).colorScheme.primaryContainer,
          //borderRadius: BorderRadius.circular(16),
          /* border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ), */
          /*  boxShadow: [
          BoxShadow(
            color: Color.fromARGB(
              128 + 64,
              128 + 64,
              128 + 64,
              128 + 64,
            ),
            blurRadius: 20, // soften the shadow
            offset: Offset(
              10, // Move to right 10  horizontally
              5, // Move to bottom 10 Vertically
            ),
          ),
        ], */
          ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (selectionMap.trueCount > 0)
              Flexible(
                child: CLText.standard(
                  ' ${selectionMap.trueCount} '
                  'of ${selectionMap.totalCount} selected',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            else
              Flexible(child: Container()),
            ElevatedButton(
              onPressed: () => onSelectAll?.call(
                select: !(selectionMap.trueCount == selectionMap.totalCount),
              ),
              child: CLText.small(
                selectionMap.trueCount == selectionMap.totalCount
                    ? 'Select None'
                    : 'Select All',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
