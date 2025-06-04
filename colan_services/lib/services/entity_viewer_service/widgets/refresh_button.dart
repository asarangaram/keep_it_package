import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RefreshButton extends ConsumerWidget {
  const RefreshButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadButton.ghost(
      onPressed: ref.read(reloadProvider.notifier).reload,
      child: const Icon(LucideIcons.refreshCcw),
    );
  }
}

class OnRefreshWrapper extends ConsumerWidget {
  const OnRefreshWrapper({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: /* isSelectionMode ? null : */
          () async => ref.read(reloadProvider.notifier).reload(),
      child: child,
    );
  }
}
