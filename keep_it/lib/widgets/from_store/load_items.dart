import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:store/store.dart';

class LoadItems extends ConsumerWidget {
  const LoadItems({
    required this.clusterID,
    required this.buildOnData,
    super.key,
    this.hasBackground = true,
  });
  final Widget Function(Items items, {required String docDir}) buildOnData;
  final int clusterID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider(clusterID));

    return FutureBuilder(
      future: getApplicationDocumentsDirectory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CLLoadingView();
        }
        if (snapshot.hasError || (snapshot.data == null)) {
          return CLErrorView(
            errorMessage:
                (snapshot.error ?? 'Failed to retrive DocDir').toString(),
          );
        }
        final docDir = (snapshot.data!).path;

        return itemsAsync.when(
          loading: () => const CLLoadingView(),
          error: (err, _) => CLErrorView(errorMessage: err.toString()),
          data: (data) => buildOnData(data, docDir: docDir),
        );
      },
    );
  }
}
