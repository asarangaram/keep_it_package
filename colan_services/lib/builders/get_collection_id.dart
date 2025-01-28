import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

class GetActiveCollectionId extends ConsumerWidget {
  const GetActiveCollectionId({required this.builder, super.key});
  final Widget Function(int? collectionId) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return builder(collectionId);
  }
}
