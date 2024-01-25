import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadCollections extends ConsumerWidget {
  const LoadCollections({
    required this.buildOnData,
    super.key,
    this.tagID,
    this.hasBackground = true,
  });
  final Widget Function(Collections collections) buildOnData;
  final int? tagID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(tagID));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
