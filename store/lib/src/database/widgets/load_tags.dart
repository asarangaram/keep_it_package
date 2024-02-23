import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadTags extends ConsumerWidget {
  const LoadTags({
    required this.buildOnData,
    super.key,
    this.collectionId,
  });
  final Widget Function(Tags tags) buildOnData;
  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider(collectionId));

    return tagsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}