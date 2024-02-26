import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/db_providers.dart';

class GetCollectionsByTagId extends ConsumerWidget {
  const GetCollectionsByTagId({
    required this.buildOnData,
    super.key,
    this.tagId,
  });
  final Widget Function(Collections collections) buildOnData;
  final int? tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(getCollectionsByTagId(tagId));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
