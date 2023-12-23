import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'keepit_dialogs.dart';

class CollectionsEmpty extends StatelessWidget {
  const CollectionsEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CLText.large(
            "Create your first collection",
          ),
          const SizedBox(
            height: 32,
          ),
          CLButtonsGrid(
            children2D: [
              [
                CLMenuItem("Suggested\nCollections", Icons.menu,
                    onTap: () => KeepItDialogs.onSuggestions(context,
                        onSelectionDone: (_) {})),
                CLMenuItem("Create New", Icons.new_label,
                    onTap: () => KeepItDialogs.upsertCollection(context))
              ]
            ],
          )
        ],
      ),
    );
  }
}
