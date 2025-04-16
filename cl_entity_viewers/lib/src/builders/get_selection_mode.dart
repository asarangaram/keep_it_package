import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';

import '../providers/select_mode.dart';

class GetSelectionMode extends ConsumerWidget {
  const GetSelectionMode({
    required this.viewIdentifier,
    required this.builder,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final Widget Function({
    required bool selectionMode,
    required ViewIdentifier viewIdentifier,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider(viewIdentifier));
    return builder(
      selectionMode: selectionMode,
      viewIdentifier: viewIdentifier,
      onUpdateSelectionmode: ({required enable}) {
        if (enable) {
          ref.read(selectModeProvider(viewIdentifier).notifier).enable();
        } else {
          ref.read(selectModeProvider(viewIdentifier).notifier).disable();
        }
      },
    );
  }
}
