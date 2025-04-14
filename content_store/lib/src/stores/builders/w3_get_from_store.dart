import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/mm_store_query.dart';

class GetFromStore extends ConsumerWidget {
  const GetFromStore({
    required this.query,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final EntityQuery query;
  final Widget Function(List<StoreEntity> entities) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitiesListenable =
        LocalStoreQueryManager(query).notifier.select((s) => s);

    return ListenableBuilder(
      listenable: entitiesListenable,
      builder: (context, child) {
        final entities = entitiesListenable.value;
        if (entities.isLoading) {
          return loadingBuilder();
        } else if (entities.errorMsg.isNotEmpty) {
          return errorBuilder(entities.errorMsg);
        }
        return builder(entities.entries);
      },
    );
  }
}
