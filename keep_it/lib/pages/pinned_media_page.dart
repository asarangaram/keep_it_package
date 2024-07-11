import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../widgets/preview.dart';
import '../widgets/store_manager.dart';

class PinnedMediaPage extends ConsumerWidget {
  const PinnedMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'pinnedMedia';
    const parentIdentifier = 'PinnedMedia';
    return StoreManager(
      builder: ({required storeAction}) {
        return GetPinnedMedia(
          buildOnData: (media) {
            return Column(
              children: [
                Expanded(
                  child: CLSimpleGalleryView<CLMedia>(
                    key: const ValueKey(label),
                    title: 'Pinned Media',
                    itemBuilder:
                        (context, item, {required quickMenuScopeKey}) => Hero(
                      tag: '$parentIdentifier /item/${item.id}',
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: StoreManager(
                          builder: ({required storeAction}) {
                            return GestureDetector(
                              onTap: () async {
                                await storeAction.openMedia(
                                  item.id!,
                                  collectionId: item.collectionId,
                                  parentIdentifier: parentIdentifier,
                                );
                              },
                              onLongPress: () => storeAction.togglePin([item]),
                              child: Preview(media: item),
                            );
                          },
                        ),
                      ),
                    ),
                    galleryMap: ref.watch(singleGroupItemProvider(media)),
                    emptyState: const Center(
                      child: CLText.large(
                        'The medias pinned to show in gallery are shown here.',
                      ),
                    ),
                    identifier: 'Pinned Media',
                    columns: 2,
                    onRefresh: () async => ref.invalidate(dbManagerProvider),
                    selectionActions: (context, items) {
                      return [
                        CLMenuItem(
                          title: 'Remove Selected Pins',
                          icon: MdiIcons.pinOffOutline,
                          onTap: () async {
                            await storeAction.togglePin(media);

                            return true;
                          },
                        ),
                      ];
                    },
                  ),
                ),
                if (media.isNotEmpty)
                  DecoratedBox(
                    decoration:
                        BoxDecoration(color: Colors.white.withAlpha(128)),
                    child: const CLText.standard(
                      'Long press to remove single item. '
                      '"Select" to remove multiple items',
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
