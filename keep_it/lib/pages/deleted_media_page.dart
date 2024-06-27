import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:store/store.dart';

import '../config/texts.dart';
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
              if (media.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.canPop()) {
                    context.pop();
                  }
                });
              }
              return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  // pop on Swipe
                  if (details.primaryVelocity! > 0) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
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
                            child: GestureDetector(
                              onTap: () async {
                                /* unawaited(
                                  context.push(
                                    '/item/${item.collectionId}/${item.id}?parentIdentifier=$parentIdentifier',
                                  ),
                                ); */
                              },
                              child: PreviewService(
                                media: item,
                                keepAspectRatio: false,
                              ),
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
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CLConfirmAction(
                                          title: 'Confirm delete',
                                          message:
                                              'Are you sure you want to delete '
                                              '${items.length} items?',
                                          child: null,
                                          onConfirm: ({required confirmed}) =>
                                              Navigator.of(context)
                                                  .pop(confirmed),
                                        );
                                      },
                                    ) ??
                                    false;
                                if (confirmed) {
                                  await dbManager.deleteMediaMultiple(
                                    items,
                                    onDeleteFile: (f) async =>
                                        f.deleteIfExists(),
                                    onRemovePinMultiple: (ids) async {
                                      /// This should not happen as
                                      /// stale media can't be pinned
                                      final res = await AlbumManager(
                                        albumName: 'KeepIt',
                                      ).removeMultipleMedia(ids);
                                      if (!res) {
                                        await ref
                                            .read(
                                              notificationMessageProvider
                                                  .notifier,
                                            )
                                            .push(
                                              CLTexts
                                                  .missingdDeletePermissionsForGallery,
                                            );
                                      }
                                      return res;
                                    },
                                  );
                                }
                                return confirmed;
                              },
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
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CLConfirmAction(
                                        title: 'Confirm delete',
                                        message:
                                            'Are you sure you want to delete '
                                            '${media.length} items?',
                                        child: null,
                                        onConfirm: ({required confirmed}) =>
                                            Navigator.of(context)
                                                .pop(confirmed),
                                      );
                                    },
                                  ) ??
                                  false;
                              if (confirmed) {
                                await dbManager.deleteMediaMultiple(
                                  media,
                                  onDeleteFile: (f) async => f.deleteIfExists(),
                                  onRemovePinMultiple: (id) async {
                                    /// This should not happen as
                                    /// stale media can't be pinned
                                    final res =
                                        await AlbumManager(albumName: 'KeepIt')
                                            .removeMultipleMedia(id);
                                    if (!res) {
                                      await ref
                                          .read(
                                            notificationMessageProvider
                                                .notifier,
                                          )
                                          .push(
                                            CLTexts
                                                .missingdDeletePermissionsForGallery,
                                          );
                                    }
                                    return res;
                                  },
                                );
                              }
                              return;
                            },
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
