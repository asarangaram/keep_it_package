import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

class PinnedMediaPage extends ConsumerWidget {
  const PinnedMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'pinnedMedia';
    const parentIdentifier = 'PinnedMedia';
    return GetStoreManager(
      builder: (theStore) {
        return GetPinnedMedia(
          buildOnData: (media) {
            return Column(
              children: [
                Expanded(
                  child: CLSimpleGalleryView<CLMedia>(
                    key: const ValueKey(label),
                    title: 'Pinned Media',
                    backButton: null,
                    itemBuilder: (
                      context,
                      item, {
                      required quickMenuScopeKey,
                    }) =>
                        Padding(
                      padding: const EdgeInsets.all(4),
                      child: GestureDetector(
                        onTap: () async {
                          await TheStore.of(context).openMedia(
                            item.id!,
                            parentIdentifier: parentIdentifier,
                            actionControl: ActionControl.full(),
                          );
                        },
                        onLongPress: () => theStore.togglePinMultiple([item]),
                        child: MediaViewService.preview(
                          item,
                          parentIdentifier: parentIdentifier,
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
                    onRefresh: () async => TheStore.of(context).reloadStore(),
                    selectionActions: (context, items) {
                      return [
                        CLMenuItem(
                          title: 'Remove Selected Pins',
                          icon: MdiIcons.pinOffOutline,
                          onTap: () async {
                            await theStore.togglePinMultiple(media);

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
