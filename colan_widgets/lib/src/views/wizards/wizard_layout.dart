import 'package:flutter/material.dart';

import '../../basics/cl_circled_icon.dart';
import '../../theme/models/cl_icons.dart';
import '../../theme/state/cl_theme.dart';
import '../appearance/cl_fullscreen_box.dart';
import '../appearance/cl_scaffold.dart';

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
  final PreferredSizeWidget? wizard;
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
          child: CLScaffold(
            bottomMenu: null,
            topMenu: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                title ?? '',
              ),
              actions: [
                if (actions != null) ...actions!.map((e) => e),
                if (onCancel != null)
                  CircledIcon(
                    clIcons.closeFullscreen,
                    onTap: onCancel,
                  ),
              ],
            ),
            banners: const [],
            body: Column(
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
            ),
          ),
        ),
      ),
    );
  }
}

class WizardLayout2 extends StatelessWidget {
  const WizardLayout2({
    required this.child,
    this.onCancel,
    this.title,
    this.wizard,
    this.actions,
    super.key,
  });
  final Widget child;
  final PreferredSizeWidget? wizard;
  final String? title;
  final List<Widget>? actions;

  final void Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all()),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Text(title ?? ''),
            actions: [
              if (actions != null) ...actions!.map((e) => e),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                    onTap: onCancel, child: Icon(clIcons.closeFullscreen)),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: child,
          ),
          bottomNavigationBar: (wizard != null)
              ? Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: wizard,
                )
              : null,
        ),
      ),
    );
  }
}
