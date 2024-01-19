import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../load_from_store/load_from_store.dart';

import '../main/keep_it_main_view.dart';
import '../receive_shared/media_preview.dart';

extension ExtItems on ItemInDB {
  CLMedia toCLMedia({String pathPrefix = ''}) {
    final p = FileHandler.join(pathPrefix, path);
    return switch (type) {
      CLMediaType.image =>
        CLMediaImage(path: p, url: ref).attachPreviewIfExits(),
      CLMediaType.video =>
        CLMediaImage(path: p, url: ref).attachPreviewIfExits(),
      _ => CLMedia(
          path: p,
          type: type,
        )
    };
  }
}

class ClustersView extends ConsumerWidget {
  const ClustersView({required this.clusters, super.key});
  final Clusters clusters;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
      pageBuilder: (context, quickMenuScopeKey) {
        return CLMatrix2D(
          itemCount: clusters.entries.length,
          itemBuilder: itemBuilder,
          columns: 2,
          layers: 2,
        );
      },
    );
  }

  Widget itemBuilder(BuildContext context, int index, int l) {
    final e = clusters.entries[index];
    if (l > 1) {
      throw Exception('has only one layer!');
    }
    if (l == 0) {
      return GestureDetector(
        onTap: () => context.push('/items/by_cluster_id/${e.id}'),
        child: LoadItems(
          clusterID: e.id!,
          hasBackground: false,
          buildOnData: (Items items, {required String docDir}) {
            final (c, r) = switch (items.entries.length) {
              1 => (1, 1),
              2 => (1, 2),
              <= 4 => (2, 2),
              < 6 => (2, 3),
              _ => (3, 3)
            };
            return MediaPreview(
              media: items.entries
                  .map(
                    (e) => e.toCLMedia(
                      pathPrefix: docDir,
                    ),
                  )
                  .toList(),
              columns: c,
              rows: r,
            );
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => context.push('/items/by_cluster_id/${e.id}'),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 8,
            bottom: 8,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              (e.description.isEmpty) ? 'Empty' : e.description,
              textAlign: TextAlign.start,
            ),
          ),
        ),
      );
    }
  }
}
