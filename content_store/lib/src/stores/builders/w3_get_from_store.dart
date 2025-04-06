import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/store_query_result.dart';

class GetFromStore extends ConsumerWidget {
  const GetFromStore({
    required this.query,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final EntityQuery query;
  final Widget Function(List<CLEntity> entities) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(entitiesProvider(query));
    return dataAsync.when(
      error: errorBuilder,
      loading: loadingBuilder,
      data: builder,
    );
  }
}
