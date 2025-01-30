import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../providers/tap_state.dart';

class GetSelectionMode extends ConsumerWidget {
  const GetSelectionMode({
    required this.viewIdentifier,
    required this.builder,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final Widget Function({
    required bool selectionMode,
    required TabIdentifier tabIdentifier,
    required void Function({required bool enable}) onUpdateSelectionmode,
  }) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currTabProvider(viewIdentifier));
    final tabIdentifier =
        TabIdentifier(view: viewIdentifier, tabId: currentTab);
    final selectionMode = ref.watch(selectModeProvider(tabIdentifier));
    return builder(
      selectionMode: selectionMode,
      tabIdentifier: tabIdentifier,
      onUpdateSelectionmode: ({required enable}) {
        ref.read(selectModeProvider(tabIdentifier).notifier).state = enable;
      },
    );
  }
}
