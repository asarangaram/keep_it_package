import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/resources.dart';

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

class GetNonEmptyCollectionsByTagId extends ConsumerWidget {
  const GetNonEmptyCollectionsByTagId({
    required this.buildOnData,
    super.key,
    this.tagId,
  });
  final Widget Function(Collections collections) buildOnData;
  final int? tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(getNonEmptyCollectionsByTagId(tagId));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
