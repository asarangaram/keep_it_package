import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collection_list_view.dart';
import 'receive_shared/media_preview.dart';
import 'receive_shared/save_or_cancel.dart';

class SharedItemsView extends ConsumerWidget {
  const SharedItemsView({
    super.key,
    required this.media,
    required this.onDiscard,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));

    return CLFullscreenBox(
        useSafeArea: true,
        hasBorder: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: MediaPreview(media: media)),
            const SizedBox(
              height: 8,
            ),
            SaveOrCancel(
              saveLabel: "Keep it",
              cancelLabel: "Discard",
              onDiscard: onDiscard,
              onSave: collectionsAsync.when(
                loading: () => null,
                error: (err, _) => null,
                data: (collections) => () => showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return CollectionListView.fromDBSelectable(
                          clusterID: null,
                          onSelectionDone: (collectionList) async {
                            List<int> ids = (collectionList)
                                .where((c) => c.id != null)
                                .map((c) => c.id!)
                                .toList();

                            // No one might be reading this, read once
                            ref.read(clustersProvider(null));
                            final clusterId = ref
                                .read(clustersProvider(null).notifier)
                                .upsertCluster(Cluster(description: ""), ids);

                            for (var entry in media.entries) {
                              switch (entry.value) {
                                case SupportedMediaType.image:
                                  // Copy item to storage.
                                  final newFile = await FileHandler.move(
                                      entry.key,
                                      toDir: "keepIt");
                                  // if URL is stored, read it and delete
                                  final logFileName = '${entry.key}.url';
                                  String? imageUrl;
                                  if (File(logFileName).existsSync()) {
                                    imageUrl =
                                        await File(logFileName).readAsString();
                                    File(logFileName).delete();
                                  }
                                  final item = Item(
                                      path: newFile,
                                      ref: imageUrl,
                                      clusterId: clusterId);
                                  ref
                                      .read(itemsProvider(clusterId).notifier)
                                      .upsertItem(item);
                                default:
                                  throw UnimplementedError();
                              }
                            }
                            onDiscard();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          onSelectionCancel: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
              ),
            )
          ],
        ));
  }
}
