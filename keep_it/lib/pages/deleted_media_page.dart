import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:store/store.dart';

import '../models/media_handler.dart';
import '../providers/gallery_group_provider.dart';

class DeleteMediaPage extends ConsumerWidget {
  const DeleteMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Deleted';
    const parentIdentifier = 'Deleted Media';
    return FullscreenLayout(
      child: GetDBManager(
        builder: (dbManager) {
          return GetDeletedMedia(
            buildOnData: (media) {
              final mediaHandler = MediaHandler.multiple(
                media: media,
                dbManager: dbManager,
              );
              if (media.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  CLPopScreen.onPop(context);
                });
              }
              return CLPopScreen.onSwipe(
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
                            child: PreviewService(
                              media: item,
                              keepAspectRatio: false,
                            ),
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
                        selectionActions: (context, items) {
                          final selectedMediaHandler = MediaHandler.multiple(
                            media: items,
                            dbManager: dbManager,
                          );
                          return [
                            CLMenuItem(
                              title: 'Restore',
                              icon: MdiIcons.imageMove,
                              onTap: () async {
                                for (final item in items) {
                                  if (item.id != null) {
                                    await dbManager.upsertMedia(
                                      collectionId: item.collectionId!,
                                      media: item.copyWith(isDeleted: false),
                                      onPrepareMedia: (
                                        m, {
                                        required targetDir,
                                      }) async {
                                        final updated = (await m.moveFile(
                                          targetDir: targetDir,
                                        ))
                                            .getMetadata();
                                        return updated;
                                      },
                                    );
                                  }
                                }
                                return true;
                              },
                            ),
                            CLMenuItem(
                              title: 'Delete',
                              icon: Icons.delete,
                              onTap: () =>
                                  selectedMediaHandler.delete(context, ref),
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
                            onPressed: () async {
                              for (final item in media) {
                                if (item.id != null) {
                                  await dbManager.upsertMedia(
                                    collectionId: item.collectionId!,
                                    media: item.copyWith(isDeleted: false),
                                    onPrepareMedia: (
                                      m, {
                                      required targetDir,
                                    }) async {
                                      final updated = (await m.moveFile(
                                        targetDir: targetDir,
                                      ))
                                          .getMetadata();
                                      return updated;
                                    },
                                  );
                                }
                              }
                            },
                            label: const CLText.small('Restore All'),
                            icon: Icon(MdiIcons.imageMove),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => mediaHandler.delete(context, ref),
                            label: const CLText.small('Discard All'),
                            icon: Icon(MdiIcons.delete),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
