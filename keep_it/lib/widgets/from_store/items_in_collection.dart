import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:store/store.dart';

class LoadItemsInCollection extends ConsumerWidget {
  const LoadItemsInCollection({
    required this.id,
    required this.buildOnData,
    super.key,
    this.limit,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final int id;
  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(
      itemsByCollectionIdProvider(
        DBQueries.byCollectionID(id, limit: limit),
      ),
    );
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
          data: (List<ItemInDB> items) => buildOnData(
            items.map((e) => e.toCLMedia(pathPrefix: docDir)).toList(),
          ),
        );
      },
    );
  }
}
