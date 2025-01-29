import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/view_modifiers.dart';
import '../providers/view_modifiers.dart';

class GetPopOverMenuItems extends ConsumerWidget {
  const GetPopOverMenuItems({
    required this.parentIdentifier,
    required this.builder,
    super.key,
  });
  final String parentIdentifier;
  final Widget Function(
    PopOverMenuItems popOverMenuItems, {
    required void Function(String name) updateCurr,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popOverMenuItems = ref.watch(popOverMenuProvider(parentIdentifier));
    return builder(
      popOverMenuItems,
      updateCurr: (name) => ref
          .read(
            popOverMenuProvider(parentIdentifier).notifier,
          )
          .updateCurr(name),
    );
  }
}
