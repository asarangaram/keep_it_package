import 'package:flutter/material.dart';

import '../../basics/cl_circled_icon.dart';
import '../../theme/state/cl_theme.dart';
import '../appearance/cl_fullscreen_box.dart';
import '../appearance/keep_it_main_view.dart';

class WizardLayout extends StatelessWidget {
  const WizardLayout({
    required this.child,
    this.onCancel,
    this.title,
    this.wizard,
    this.actions,
    super.key,
  });
  final Widget child;
  final Widget? wizard;
  final String? title;
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
        // color: Colors.blue,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: CLBackground(
          child: KeepItMainView(
            title: title ?? '',
            backButton: null,
            actionsBuilder: [
              if (actions != null)
                ...actions!.map((e) => (context, quickMenuScopeKey) => e),
              if (onCancel != null)
                (context, quickMenuScopeKey) => CircledIcon(
                      Icons.close,
                      onTap: onCancel,
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
      ),
    );
  }
}
