import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/mm_db.dart';

/* class GetStores extends ConsumerWidget {
  const GetStores({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(Map<String, CLStore>) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(storesProvider);
    return stores.when(
      data: builder,
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
} */

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.storeIdentity,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final String storeIdentity;
  final Widget Function(CLStore) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeNotifier = localStoreNotifierManager.notifier.select((s) => s);

    return ListenableBuilder(
      listenable: storeNotifier,
      builder: (context, child) {
        final store = storeNotifier.value;
        if (store.isLoading) {
          return loadingBuilder();
        } else if (store.errorMsg.isNotEmpty) {
          return errorBuilder(store.errorMsg);
        }
        return builder(store);
      },
    );
  }
}
