import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../load_from_store/load_items.dart';
import '../main/keep_it_main_view.dart';
import '../receive_shared/media_preview.dart';

class ClustersView extends ConsumerWidget {
  const ClustersView({super.key, required this.clusters});
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
        return CLGridViewCustom(
          showAll: true,
          maxCrossAxisCount: 2,
          children: clusters.entries
              .map((e) => [
                    GestureDetector(
                      //onTap: context.go(location),
                      child: LoadItems(
                        clusterID: e.id,
                        hasBackground: false,
                        buildOnData: (items) {
                          return MediaPreview.fromItems(
                            items,
                          );
                        },
                      ),
                    ),
                    if (e.description.isNotEmpty)
                      GestureDetector(
                        // onTap: ,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 8, bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              e.description,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      )
                  ])
              .toList(),
        );
      },
    );
  }
}
