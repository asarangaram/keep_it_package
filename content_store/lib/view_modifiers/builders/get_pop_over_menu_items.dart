import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../models/view_modifiers.dart';
import '../providers/view_modifiers.dart';

class GetPopOverMenuItems extends ConsumerWidget {
  const GetPopOverMenuItems({
    required this.tabIdentifier,
    required this.builder,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final Widget Function(
    PopOverMenuItems popOverMenuItems, {
    required void Function(String name) updateCurr,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popOverMenuItems = ref.watch(popOverMenuProvider(tabIdentifier));
    return builder(
      popOverMenuItems,
      updateCurr: (name) => ref
          .read(
            popOverMenuProvider(tabIdentifier).notifier,
          )
          .updateCurr(name),
    );
  }
}
