import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';


class SelectionCountView extends StatelessWidget {
  const SelectionCountView({
    required this.child,
    super.key,
    this.buttonLabel,
    this.onPressed,
  });
  final Widget child;
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
            Flexible(
              child: child,
            ),
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
