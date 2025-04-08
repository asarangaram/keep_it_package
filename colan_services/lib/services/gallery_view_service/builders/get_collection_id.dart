import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/active_collection.dart';

class GetActiveCollectionId extends ConsumerWidget {
  const GetActiveCollectionId({required this.builder, super.key});
  final Widget Function(StoreEntity? parentId) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider);
    return builder(parentId);
  }
}
