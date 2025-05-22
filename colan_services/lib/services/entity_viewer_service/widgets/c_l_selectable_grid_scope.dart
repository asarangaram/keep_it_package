import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLSelectableGridScope extends ConsumerWidget {
  const CLSelectableGridScope({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        selectModeProvider.overrideWith((ref) => SelectModeNotifier()),
      ],
      child: child,
    );
  }
}
