import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:store/store.dart';

import '../providers/gallery_group_provider.dart';

class StaleMediaPage extends ConsumerWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Unclassified Media';
    const parentIdentifier = 'Unclassified Media';
    return FullscreenLayout(
      child: GetDBManager(
        builder: (dbManager) {
          return GetStaleMedia(
            buildOnData: (media) {
              if (media.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.pop();
                });
              }
              return Column(
                children: [
                  Expanded(
                    child: CLSimpleGalleryView<CLMedia>(
                      key: const ValueKey(label),
                      title: 'Unclassified  Media',
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
                                onPin:
                                    AlbumManager(albumName: 'KeepIt').addMedia,
                                onRemovePin: (id) async {
                                  final res =
                                      await AlbumManager(albumName: 'KeepIt')
                                          .removeMedia(id);
                                  if (!res) {
                                    await ref
                                        .read(
                                          notificationMessageProvider.notifier,
                                        )
                                        .push(
                                          "'Give Permission to "
                                          "remove from Gallery'",
                                        );
                                  }
                                  return res;
                                },
                              );
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
                          'The medias pinned to show in gallery are shown here.',
                        ),
                      ),
                      identifier: 'Pinned Media',
                      columns: 2,
                      selectionActions: (context, items) {
                        return [
                          CLMenuItem(
                            title: 'Move',
                            icon: MdiIcons.imageMove,
                            onTap: () async {
                              final result = await context.push<bool>(
                                '/move?ids=${items.map((e) => e.id).join(',')}&unhide=true',
                              );

                              return result;
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
                                  onDeleteFile: (f) async => f.deleteIfExists(),
                                  onRemovePin: (id) async {
                                    /// This should not happen as
                                    /// stale media can't be pinned
                                    final res =
                                        await AlbumManager(albumName: 'KeepIt')
                                            .removeMedia(id);
                                    if (!res) {
                                      await ref
                                          .read(
                                            notificationMessageProvider
                                                .notifier,
                                          )
                                          .push(
                                            "'Give Permission to "
                                            "remove from Gallery'",
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
                          onPressed: () {
                            context.push<bool>(
                              '/move?ids=${media.map((e) => e.id).join(',')}&unhide=true',
                            );
                          },
                          label: const CLText.small('Keep All'),
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
                                          Navigator.of(context).pop(confirmed),
                                    );
                                  },
                                ) ??
                                false;
                            if (confirmed) {
                              await dbManager.deleteMediaMultiple(
                                media,
                                onDeleteFile: (f) async => f.deleteIfExists(),
                                onRemovePin: (id) async {
                                  /// This should not happen as
                                  /// stale media can't be pinned
                                  final res =
                                      await AlbumManager(albumName: 'KeepIt')
                                          .removeMedia(id);
                                  if (!res) {
                                    await ref
                                        .read(
                                          notificationMessageProvider.notifier,
                                        )
                                        .push(
                                          "'Give Permission to "
                                          "remove from Gallery'",
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
              );
            },
          );
        },
      ),
    );
  }
}
