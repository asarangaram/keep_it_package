import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/select_mode.dart';

class GetSelectionMode extends ConsumerWidget {
  const GetSelectionMode({
    required this.builder,
    super.key,
  });

  final Widget Function({
    required bool selectionMode,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider);
    return builder(
      selectionMode: selectionMode,
      onUpdateSelectionmode: ({required enable}) {
        if (enable) {
          ref.read(selectModeProvider.notifier).enable();
        } else {
          ref.read(selectModeProvider.notifier).disable();
        }
      },
    );
  }
}
