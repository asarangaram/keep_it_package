import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class KeepItMainView extends StatelessWidget {
  const KeepItMainView({
    required this.child,
    required this.backButton,
    super.key,
    this.actions,
    this.title,
  });
  final Widget child;
  final List<Widget>? actions;

  final String? title;
  final Widget? backButton;

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: title == null ? null : CLLabel.large(title!),
        leading: backButton,
        actions: [
          if (actions != null && actions!.isNotEmpty)
            ...actions!.map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: e,
              ),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }
}
