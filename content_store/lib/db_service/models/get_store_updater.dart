import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/store_updater.dart';
import 'store_updater.dart';

class GetStoreUpdater extends ConsumerWidget {
  const GetStoreUpdater({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(StoreUpdater store) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeUpdaterProvider);

    return storeAsync.when(
      data: builder,
      error: errorBuilder ?? (_, __) => Container(),
      loading: loadingBuilder ?? Container.new,
    );
  }
}
