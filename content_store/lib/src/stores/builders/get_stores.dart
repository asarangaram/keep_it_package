import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/stores.dart';

class GetStores extends ConsumerWidget {
  const GetStores({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(Map<String, CLStore>) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
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
}

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
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(storesProvider);

    return storesAsync.when(
      data: (stores) {
        try {
          if (stores.keys.contains(storeIdentity)) {
            return builder(stores[storeIdentity]!);
          }
          throw Exception('store not found');
        } catch (e, st) {
          return errorBuilder(e, st);
        }
      },
      error: errorBuilder,
      loading: loadingBuilder,
    );
  }
}
