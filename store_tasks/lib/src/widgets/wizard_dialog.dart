import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WizardDialog2 extends StatelessWidget implements PreferredSizeWidget {
  const WizardDialog2({
    required this.child,
    this.option1,
    super.key,
    this.fixedHeight = true,
  });
  final Widget child;
  final CLMenuItem? option1;

  final bool fixedHeight;

  @override
  Widget build(BuildContext context) {
    final widget = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 2,
                          color: ShadTheme.of(context).colorScheme.muted))),
              child: child,
            )),
        Expanded(
          child: GestureDetector(
            onTap: option1?.onTap,
            child: Container(
              margin: const EdgeInsets.only(left: 1),
              decoration: BoxDecoration(
                color: CLTheme.of(context).colors.wizardButtonBackgroundColor,
                border: const Border(
                  top: BorderSide(
                    color: Colors.transparent,
                  ),
                  left: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, left: 2),
                  child: FittedBox(
                    child: CLLabel.large(
                      option1!.title,
                      color: option1!.onTap == null
                          ? Colors.grey
                          : CLTheme.of(context)
                              .colors
                              .wizardButtonForegroundColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    if (fixedHeight) {
      return SizedBox(
        height: kMinInteractiveDimension * 2,
        child: widget,
      );
    }
    return widget;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}
