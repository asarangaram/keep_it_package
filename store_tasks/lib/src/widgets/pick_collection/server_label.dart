import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class ServerLabel extends ConsumerWidget {
  const ServerLabel({required this.store, super.key});
  final CLStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = store.store.identity == 'default'
        ? 'On this device'
        : store.store.identity;
    final Color color;
    switch (store.store.storeURL.scheme) {
      case 'http':
      case 'https':
        color = Colors.green; // When offline, change to red
      default:
        color = Colors.grey.shade400;
    }
    return Text(
      label,
      style: ShadTheme.of(context).textTheme.muted.copyWith(color: color),
    );
  }
}
