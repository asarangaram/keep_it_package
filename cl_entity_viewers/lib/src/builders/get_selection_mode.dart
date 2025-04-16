import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';

import '../providers/select_mode.dart';

class GetSelectionMode extends ConsumerWidget {
  const GetSelectionMode({
    required this.tabIdentifier,
    required this.builder,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final Widget Function({
    required bool selectionMode,
    required TabIdentifier tabIdentifier,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider(tabIdentifier));
    return builder(
      selectionMode: selectionMode,
      tabIdentifier: tabIdentifier,
      onUpdateSelectionmode: ({required enable}) {
        if (enable) {
          ref.read(selectModeProvider(tabIdentifier).notifier).enable();
        } else {
          ref.read(selectModeProvider(tabIdentifier).notifier).disable();
        }
      },
    );
  }
}
