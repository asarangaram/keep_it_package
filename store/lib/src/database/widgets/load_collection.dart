import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/db_collection.dart';

class LoadCollection extends ConsumerWidget {
  const LoadCollection({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(Collection collections) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionProvider(id));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
