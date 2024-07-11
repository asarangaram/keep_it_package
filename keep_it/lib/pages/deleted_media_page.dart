import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../widgets/preview.dart';
import '../widgets/store_manager.dart';

class DeleteMediaPage extends ConsumerWidget {
  const DeleteMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Deleted';
    const parentIdentifier = 'Deleted Media';
    return StoreManager(
      builder: ({required storeAction}) {
        return GetDeletedMedia(
          buildOnData: (media) {
            if (media.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CLPopScreen.onPop(context);
              });
            }
            return FullscreenLayout(
              child: CLPopScreen.onSwipe(
                child: Column(
                  children: [
                    Expanded(
                      child: CLSimpleGalleryView<CLMedia>(
                        key: const ValueKey(label),
                        title: 'Deleted Media',
                        itemBuilder: (
                          context,
                          item, {
                          required quickMenuScopeKey,
                        }) =>
                            Hero(
                          tag: '$parentIdentifier /item/${item.id}',
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Preview(media: item),
                          ),
                        ),
                        galleryMap: ref.watch(singleGroupItemProvider(media)),
                        emptyState: const Center(
                          child: CLText.large(
                            'The medias pinned to show '
                            'in gallery are shown here.',
                          ),
                        ),
                        identifier: 'Pinned Media',
                        columns: 2,
                        selectionActions: (context, selectedMedia) {
                          return [
                            CLMenuItem(
                              title: 'Restore',
                              icon: MdiIcons.imageMove,
                              onTap: () async =>
                                  ConfirmAction.restoreMediaMultiple(
                                context,
                                media: selectedMedia,
                                getPreview: (media) => Preview(
                                  media: media,
                                ),
                                onConfirm: () => storeAction.restoreDeleted(
                                  selectedMedia,
                                  confirmed: true,
                                ),
                              ),
                            ),
                            CLMenuItem(
                              title: 'Delete',
                              icon: Icons.delete,
                              onTap: () async =>
                                  ConfirmAction.deleteMediaMultiple(
                                context,
                                media: selectedMedia,
                                getPreview: (media) => Preview(
                                  media: media,
                                ),
                                onConfirm: () => storeAction
                                    .delete(selectedMedia, confirmed: true),
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async =>
                                ConfirmAction.restoreMediaMultiple(
                              context,
                              media: media,
                              getPreview: (media) => Preview(
                                media: media,
                              ),
                              onConfirm: () => storeAction.restoreDeleted(
                                media,
                                confirmed: true,
                              ),
                            ),
                            label: const CLText.small('Restore All'),
                            icon: Icon(MdiIcons.imageMove),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async =>
                                ConfirmAction.deleteMediaMultiple(
                              context,
                              media: media,
                              getPreview: (media) => Preview(
                                media: media,
                              ),
                              onConfirm: () =>
                                  storeAction.delete(media, confirmed: true),
                            ),
                            label: const CLText.small('Discard All'),
                            icon: Icon(MdiIcons.delete),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
