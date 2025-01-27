import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../../basics/cl_text.dart';
import 'cl_fullscreen_box.dart';

class KeepItMainView extends StatelessWidget {
  const KeepItMainView({
    required this.child,
    required this.backButton,
    required this.popupActionItems,
    super.key,
    this.actions,
    this.title,
  });
  final Widget child;
  final List<Widget>? actions;
  final List<CLMenuItem> popupActionItems;

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
        automaticallyImplyLeading: false,
        actions: [
          if (actions != null && actions!.isNotEmpty)
            ...actions!.map(
              (e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: e,
              ),
            ),
          if (popupActionItems.isNotEmpty)
            PopupMenuButton<CLMenuItem>(
              onSelected: (CLMenuItem item) {
                item.onTap?.call();
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<CLMenuItem>>[
                  for (final item in popupActionItems) ...[
                    PopupMenuItem<CLMenuItem>(
                      value: item,
                      child: ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.title),
                      ),
                    ),
                  ],
                ];
              },
              child: const Icon(Icons.more_vert),
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
