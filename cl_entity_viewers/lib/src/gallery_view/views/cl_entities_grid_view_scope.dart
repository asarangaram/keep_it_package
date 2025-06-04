import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/select_mode.dart';

class CLEntitiesGridViewScope extends ConsumerWidget {
  const CLEntitiesGridViewScope({required this.child, super.key});
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
