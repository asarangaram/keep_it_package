import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../widgets/folders_and_files/media_as_file.dart';

class PinnedMediaPage extends ConsumerWidget {
  const PinnedMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'pinnedMedia';
    const parentIdentifier = 'PinnedMedia';
    return GetDBManager(
      builder: (dbManager) {
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
                        child: GestureDetector(
                          onTap: () async {
                            unawaited(
                              context.push(
                                '/item/${item.collectionId}/${item.id}?parentIdentifier=$parentIdentifier',
                              ),
                            );
                          },
                          onLongPress: () async {
                            await dbManager.togglePin(
                              item,
                              onPin: AlbumManager(albumName: 'KeepIt').addMedia,
                              onRemovePin:
                                  AlbumManager(albumName: 'KeepIt').removeMedia,
                            );
                          },
                          child: Stack(
                            children: [
                              PreviewService(
                                media: item,
                                keepAspectRatio: false,
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.3,
                                    heightFactor: 0.3,
                                    child: FittedBox(
                                      child: CLIcon.veryLarge(
                                        MdiIcons.pin,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    galleryMap: [
                      if (media.isNotEmpty)
                        GalleryGroup(
                          media,
                        ),
                    ],
                    emptyState: const Center(
                      child: CLText.large(
                        'The medias pinned to show in gallery are listed here.',
                      ),
                    ),
                    identifier: 'Pinned Media',
                    columns: 2,
                    selectionActions: (context, items) {
                      return [
                        CLMenuItem(
                          title: 'Remove Selected Pins',
                          icon: MdiIcons.pinOffOutline,
                          onTap: () async {
                            await dbManager.unpinMediaMultiple(
                              media,
                              onRemovePinMultiple:
                                  AlbumManager(albumName: 'KeepIt')
                                      .removeMultipleMedia,
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
    );
  }
}
