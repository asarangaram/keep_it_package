import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../navigation/providers/active_collection.dart';

class SelectControlIcon extends ConsumerWidget {
  const SelectControlIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final identifier = ref.watch(mainPageIdentifierProvider);
    if (collectionId == null) {
      return const SizedBox.shrink();
    }
    final selectionMode = ref.watch(selectModeProvider(identifier));

    return CLButtonText.small(
      selectionMode ? 'Done' : 'Select',
      onTap: () {
        ref.watch(selectModeProvider(identifier).notifier).state =
            !selectionMode;
      },
    );
  }
}
