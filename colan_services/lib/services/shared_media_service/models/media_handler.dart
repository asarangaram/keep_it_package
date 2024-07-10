import 'dart:async';
import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:share_plus/share_plus.dart';
import 'package:store/store.dart';

import 'album_manager_helper.dart';

class MediaHandler {
  MediaHandler({
    required CLMedia media,
    required this.dbManager,
  }) : media = [media];

  MediaHandler.multiple({
    required this.media,
    required this.dbManager,
  });
  final List<CLMedia> media;
  final DBManager dbManager;

  Future<bool> move(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }

    await MediaWizardService.addMedia(
      context,
      ref,
      media: CLSharedMedia(entries: media, type: MediaSourceType.move),
    );
    if (context.mounted) {
      await context.push(
        '/media_wizard?type='
        '${MediaSourceType.move.name}',
      );
    }
    return true;
  }

  Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    'this ${media[0].type.name}?',
                child: PreviewService(media: media[0]),
                onConfirm: ({required confirmed}) async {
                  if (context.mounted) {
                    Navigator.of(context).pop(confirmed);
                  }
                },
              );
            },
          ) ??
          false;
      if (confirmed) {
        await dbManager.deleteMedia(
          media[0],
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePin: (id) async =>
              AlbumManagerHelper().removeMedia(context, ref, id),
        );
        return true;
      }
      return false;
    } else {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
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
          onRemovePinMultiple: (id) async =>
              AlbumManagerHelper().removeMultipleMedia(context, ref, id),
        );
      }
      return confirmed;
    }
  }

  Future<bool> share(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }

    final box = context.findRenderObject() as RenderBox?;
    final files = media.map((e) => XFile(e.path)).toList();
    final shareResult = await Share.shareXFiles(
      files,
      // text: 'Share from KeepIT',
      subject: 'Exporting media from KeepIt',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
    return switch (shareResult.status) {
      ShareResultStatus.dismissed => false,
      ShareResultStatus.unavailable => false,
      ShareResultStatus.success => true,
    };
  }

  Future<bool> edit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      if (media[0].pin != null) {
        await ref.read(notificationMessageProvider.notifier).push(
              "Unpin to edit.\n Pinned items can't be edited",
            );
        return true;
      } else {
        // TODO(anandas):  Try moving this to app
        await context.push('/mediaEditor?id=${media[0].id}');
        return true;
      }
    }
    return false;
  }

  Future<bool> togglePin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      await dbManager.togglePin(
        media[0],
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    } else {
      await dbManager.pinMediaMultiple(
        media,
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    }
  }

  Future<bool> save(
    BuildContext context,
    WidgetRef ref,
    String outFile, {
    required bool overwrite,
  }) async {
    if (media.isEmpty) {
      return true;
    }
    if (media.length == 1) {
      if (overwrite) {
        final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return CLConfirmAction(
                  title: 'Confirm '
                      '${overwrite ? "Replace" : "Save New"} ',
                  message: '',
                  child: PreviewService(
                    media: CLMedia(
                      path: outFile,
                      type: media[0].type,
                    ),
                    keepAspectRatio: false,
                  ),
                  onConfirm: ({required confirmed}) =>
                      Navigator.of(context).pop(confirmed),
                );
              },
            ) ??
            false;
        if (!confirmed) return false;
      }
      final md5String = await File(outFile).checksum;
      final CLMedia updatedMedia;
      if (overwrite) {
        updatedMedia =
            media[0].copyWith(path: outFile, md5String: md5String).removePin();
      } else {
        updatedMedia = CLMedia(
          path: outFile,
          md5String: md5String,
          type: media[0].type,
          collectionId: media[0].collectionId,
          originalDate: media[0].originalDate,
          createdDate: media[0].createdDate,
          isDeleted: media[0].isDeleted,
          isHidden: media[0].isHidden,
          updatedDate: media[0].updatedDate,
        );
      }
      await dbManager.upsertMedia(
        collectionId: media[0].collectionId!,
        media: updatedMedia,
        onPrepareMedia: (m, {required targetDir}) async {
          final updated = await m.moveFile(targetDir: targetDir);

          return updated;
        },
      );
      if (overwrite) {
        await File(media[0].path).deleteIfExists();
      }
    }
    return false;
  }

  //Can be converted to non static
  static Stream<Progress> acceptMedia(
    DBManager dbManager, {
    required Collection collection,
    required List<CLMedia>? media,
    required void Function() onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection = await dbManager.upsertCollection(
        collection: collection,
      );
    } else {
      updatedCollection = collection;
    }
    if (media?.isNotEmpty ?? false) {
      final streamController = StreamController<Progress>();
      var completedMedia = 0;
      unawaited(
        dbManager
            .upsertMediaMultiple(
          media: media?.map((e) => e.copyWith(isHidden: false)).toList(),
          collectionId: updatedCollection.id!,
          onPrepareMedia: (m, {required targetDir}) async {
            final updated =
                (await m.moveFile(targetDir: targetDir)).getMetadata();
            completedMedia++;

            streamController.add(
              Progress(
                fractCompleted: completedMedia / media!.length,
                currentItem: m.basename,
              ),
            );
            await Future<void>.delayed(const Duration(microseconds: 1));
            return updated;
          },
        )
            .then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Successfully Imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 10));
          await streamController.close();
          onDone();
        }),
      );
      yield* streamController.stream;
    }
  }
}
