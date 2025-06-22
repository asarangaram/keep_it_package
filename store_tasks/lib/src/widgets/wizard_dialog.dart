import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WizardDialog2 extends StatelessWidget implements PreferredSizeWidget {
  const WizardDialog2({
    required this.child,
    this.content,
    this.option1,
    this.option2,
    super.key,
    this.fixedHeight = true,
  });
  final Widget? content;
  final CLMenuItem? option1;
  final CLMenuItem? option2;
  final Widget child;
  final bool fixedHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fixedHeight ? kMinInteractiveDimension * 3 : null,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension * 3);
}
