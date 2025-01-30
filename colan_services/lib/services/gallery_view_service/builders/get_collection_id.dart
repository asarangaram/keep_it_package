import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_collection.dart';

class GetActiveCollectionId extends ConsumerWidget {
  const GetActiveCollectionId({required this.builder, super.key});
  final Widget Function(int? collectionId) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return builder(collectionId);
  }
}
