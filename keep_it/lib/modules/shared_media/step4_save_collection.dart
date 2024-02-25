import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

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
    final updater = ref.watch(dbUpdaterNotifierProvider.notifier);
    return StreamProgressView(
      stream: () => updater.upsertMediaList(
        media: incomingMedia,
        onDone: onDone,
      ),
      onCancel: onCancel,
    );
  }
}
