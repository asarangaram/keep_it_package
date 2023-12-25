import 'dart:io';
import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/collections_page/keepit_dialogs.dart';
import 'package:store/store.dart';

import 'collections_page/collections_from_db.dart';
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
    return CLFullscreenBox(
      useSafeArea: false,
      child: CollectionsFromDB(
        buildOnData: (collections) {
          return SafeArea(
            child: SizedBox(
              width: min(MediaQuery.of(context).size.width, 450),
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
                    onSave: () => KeepItDialogs.selectCollections(
                      context,
                      onSelectionDone:
                          (List<Collection> selectedCollections) async {
                        await onSelectionDone(
                            context, ref, selectedCollections);
                        if (context.mounted) {
                          CLButtonsGrid.showSnackBarAboveDialog(
                              context, "Item(s) Saved",
                              onSnackBarRemoved: onDiscard);
                        }
                        // onDiscard();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  /*
  
               */

  onSelectionDone(
    BuildContext context,
    WidgetRef ref,
    List<Collection> collectionList,
  ) async {
    List<int> ids =
        (collectionList).where((c) => c.id != null).map((c) => c.id!).toList();

    // No one might be reading this, read once
    ref.read(clustersProvider(null));
    final clusterId = ref
        .read(clustersProvider(null).notifier)
        .upsertCluster(Cluster(description: ""), ids);

    for (var entry in media.entries) {
      switch (entry.value) {
        case SupportedMediaType.image:
        case SupportedMediaType.video:
          // Copy item to storage.
          final newFile = await FileHandler.move(entry.key, toDir: "keepIt");
          // if URL is stored, read it and delete
          final logFileName = '${entry.key}.url';
          String? imageUrl;
          if (File(logFileName).existsSync()) {
            imageUrl = await File(logFileName).readAsString();
            File(logFileName).delete();
          }
          final item = Item(path: newFile, ref: imageUrl, clusterId: clusterId);
          ref.read(itemsProvider(clusterId).notifier).upsertItem(item);

        default:
          throw UnimplementedError();
      }
    }
  }
}
