import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../model/selector.dart';
import '../providers/selector.dart';

class SelectionCount extends ConsumerWidget {
  const SelectionCount({super.key, this.groupEntities = const []});
  final List<GalleryGroupCLEntity> groupEntities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selector = ref.watch(selectorProvider);

    final total = groupEntities.getEntityIds;
    final selected = selector.count;
    final allSelected =
        selector.isSelected(groupEntities.getEntities.toList()) ==
            SelectionStatus.selectedAll;
    return SelectionCountView(
      selectionMsg: selected == 0
          ? null
          : ' $selected '
              'of $total selected',
      buttonLabel: allSelected ? 'Select None' : 'Select All',
      onPressed: () => ref
          .read(selectorProvider.notifier)
          .toggle(groupEntities.getEntities.toList()),
    );
  }
}

class SelectionCountView extends StatelessWidget {
  const SelectionCountView({
    super.key,
    this.selectionMsg,
    this.buttonLabel,
    this.onPressed,
  });
  final String? selectionMsg;
  final String? buttonLabel;
  final void Function()? onPressed;

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
            if (selectionMsg != null)
              Flexible(
                child: CLText.standard(
                  selectionMsg!,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            else
              Flexible(child: Container()),
            if (buttonLabel != null)
              ElevatedButton(
                onPressed: onPressed,
                child: CLText.small(
                  buttonLabel!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* 
' ${selectionMap.trueCount} '
                  'of ${selectionMap.totalCount} selected',

() => onSelectAll?.call(
                  select: !(selectionMap.trueCount == selectionMap.totalCount),
                )
                  selectionMap.trueCount == selectionMap.totalCount
                    ? 'Select None'
                    : ,
*/
