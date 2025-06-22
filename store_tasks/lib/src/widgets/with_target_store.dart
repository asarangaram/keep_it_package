import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class WithTargetStore extends ConsumerWidget {
  const WithTargetStore(
      {required this.builder,
      required this.errorBuilder,
      required this.loadingBuilder,
      this.collection,
      super.key});
  final Widget Function() builder;
  final Widget Function([Object? e, StackTrace? st]) errorBuilder;
  final Widget Function() loadingBuilder;
  final StoreEntity? collection;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* final store =  */
    return GetActiveStore(
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        builder: (activeStore) {
          return ProviderScope(overrides: [
            targetStoreProvider
                .overrideWith((ref) => collection?.store ?? activeStore)
          ], child: builder());
        });
  }
}

final targetStoreProvider = StateProvider<CLStore>((ref) {
  throw Exception('Must override targetStoreProvider');
});
