import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/store_updater.dart';

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(Store store) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeUpdaterProvider);

    return storeAsync.when(
      data: (storeUpdater) => builder(storeUpdater.store),
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
