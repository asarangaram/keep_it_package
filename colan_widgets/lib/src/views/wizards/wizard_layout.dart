import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class WizardLayout extends StatelessWidget {
  const WizardLayout({
    required this.child,
    required this.title,
    required this.onCancel,
    this.wizard,
    this.actions,
    super.key,
  });
  final Widget child;
  final Widget? wizard;
  final String title;
  final List<Widget>? actions;

  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    /*  
          Do we need ClipRRect?? 
          
          */
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: CLTheme.of(context).colors.wizardButtonBackgroundColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: KeepItMainView(
          title: title,
          actionsBuilder: [
            if (actions != null)
              ...actions!.map((e) => (context, quickMenuScopeKey) => e),
            (context, quickMenuScopeKey) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CLTheme.of(context)
                            .colors
                            .iconBackgroundTransparent,
                      ),
                      child: CLButtonIcon.small(
                        Icons.close,
                        color: CLTheme.of(context).colors.iconColorTransparent,
                        onTap: onCancel,
                      ),
                    ),
                  ),
                ),
          ],
          pageBuilder: (context, quickMenuScopeKey) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: child),
                /* const Divider(
                  height: 16,
                  thickness: 1,
                  indent: 8,
                  endIndent: 8,
                  color: Colors.black,
                ), */
                if (wizard != null) ...[
                  const SizedBox(
                    height: 16,
                  ),
                  wizard!,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
