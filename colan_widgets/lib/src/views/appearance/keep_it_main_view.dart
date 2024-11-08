import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class KeepItMainView extends StatelessWidget {
  const KeepItMainView({
    required this.child,
    this.leading,
    this.actions,
    this.title,
    this.bottomWidgets,
    super.key,
  });
  final Widget child;
  final List<Widget>? actions;
  final String? title;
  final Widget? leading;
  final List<Widget>? bottomWidgets;

  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: title == null ? null : CLLabel.large(title!),
        leading: leading,
        actions: [
          if (actions != null && actions!.isNotEmpty)
            ...actions!.map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: e,
              ),
            ),
          ...[
            const Icon(Icons.filter_list),
            const Icon(Icons.settings),
            const Icon(Icons.more_vert),
          ].map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: e,
            ),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          children: [
            Expanded(child: child),
            if (bottomWidgets != null) ...bottomWidgets!,
          ],
        ),
      ),
    );
  }
}
