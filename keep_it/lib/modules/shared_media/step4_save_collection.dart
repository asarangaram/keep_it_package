import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wizard_page.dart';

class SaveCollection extends SharedMediaWizard {
  const SaveCollection({
    required super.incomingMedia,
    required super.onDone,
    required super.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamProgressView(
      stream: () => CLMediaProcess.acceptMedia(
        media: incomingMedia,
        onDone: (CLMediaList mg) async {
          onDone(mg: null);
        },
      ),
      onCancel: onCancel,
    );
  }
}
