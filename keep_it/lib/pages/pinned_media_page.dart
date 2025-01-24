import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PinnedMediaPage extends ConsumerWidget {
  const PinnedMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw Exception(UnimplementedError);
    /*  const label = 'pinnedMedia';
    const parentIdentifier = 'PinnedMedia';
    return GetStoreUpdater(
      builder: (theStore) {
        return GetPinnedMedia(
          errorBuilder: null,
          loadingBuilder: () => CLLoader.widget(debugMessage: ,),
          builder: (media) {
            return Column(
              children: [
                Expanded(
                  child: MediaGalleryView(
                    key: const ValueKey(label),
                    itemBuilder: (context, item) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: GestureDetector(
                        onTap: () async {
                          await PageManager.of(context, ref).openMedia(
                            item.id!,
                            parentIdentifier: parentIdentifier,
                          );
                        },
                        onLongPress: () =>
                            theStore.mediaUpdater.pinToggle(item.id!),
                        child: MediaViewService.preview(
                          item,
                          parentIdentifier: parentIdentifier,
                        ),
                      ),
                    ),
                    medias: media,
                    emptyState: const Center(
                      child: CLText.large(
                        'The medias pinned to show in gallery are shown here.',
                      ),
                    ),
                    identifier: 'Pinned Media',
                    columns: 2,
                    onRefresh: () async => theStore.store.reloadStore(),
                    selectionActions: (context, items) {
                      return [
                        CLMenuItem(
                          title: 'Remove Selected Pins',
                          icon: clIcons.unPinAll,
                          onTap: () async {
                            await theStore.mediaUpdater.pinToggleMultiple(
                              media.entries.map((e) => e.id).toSet(),
                            );

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
    ); */
  }
}
