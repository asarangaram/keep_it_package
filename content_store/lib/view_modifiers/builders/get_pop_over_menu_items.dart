import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/view_modifier.dart';
import '../providers/view_modifiers.dart';

class GetViewModifiers extends ConsumerWidget {
  const GetViewModifiers({
    required this.tabIdentifier,
    required this.builder,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final Widget Function(
    List<ViewModifier> viewModifiers,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(viewModifiersProvider(tabIdentifier));
    return builder(items);
  }
}
