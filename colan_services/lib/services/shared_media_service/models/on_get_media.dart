// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:store/store.dart';

import '../../media_wizard_service/media_wizard_service.dart';
import '../../media_wizard_service/models/types.dart';
import '../../notification_services/provider/notify.dart';
import '../../preview_service/view/preview.dart';
import 'album_manager_helper.dart';
import 'cl_shared_media.dart';

@immutable
class MediaActions {
  final Future<bool> Function(List<CLMedia> selectedMedia) move;
  final Future<bool> Function(List<CLMedia> selectedMedia) delete;
  final Future<bool> Function(List<CLMedia> selectedMedia) share;
  final Future<bool> Function(List<CLMedia> selectedMedia) togglePin;
  final Future<bool> Function(List<CLMedia> selectedMedia) edit;

  final Future<bool> Function(List<CLMedia> selectedMedia) restoreDeleted;

  final Future<bool> Function(List<CLMedia> selectedMedia, String outFile)
      replaceMedia;

  final Future<bool> Function(List<CLMedia> selectedMedia, String outFile)
      cloneAndReplaceMedia;

  final Future<CLMedia?> Function(
    String path, {
    required bool isVideo,
    Collection? collection,
  }) newMedia;

  final Stream<Progress> Function(
    List<CLMedia> selectedMedia, {
    required Collection collection,
    required void Function() onDone,
  }) moveToCollectionStream;

  final Stream<Progress> Function({
    required CLSharedMedia media,
    required void Function({
      required CLSharedMedia mg,
    }) onDone,
  }) analyseMediaStream;

  final Future<String> Function({required String ext}) createTempFile;

  final Future<void> Function(CLMedia media, CLNote note) onUpsertNote;
  final Future<void> Function(CLNote note) onDeleteNote;

  const MediaActions({
    required this.move,
    required this.delete,
    required this.share,
    required this.togglePin,
    required this.edit,
    required this.restoreDeleted,
    required this.replaceMedia,
    required this.cloneAndReplaceMedia,
    required this.moveToCollectionStream,
    required this.newMedia,
    required this.analyseMediaStream,
    required this.createTempFile,
    required this.onUpsertNote,
    required this.onDeleteNote,
  });
}

class MediaHandlerWidget extends StatelessWidget {
  const MediaHandlerWidget({
    required this.builder,
    super.key,
  });

  final Widget Function({required MediaActions action})? builder;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return GetDBManager(
          builder: (dbManager) {
            return MediaHandlerWidget0(
              dbManager: dbManager,
              appSettings: appSettings,
              builder: builder,
            );
          },
        );
      },
    );
  }
}

class MediaHandlerWidget0 extends ConsumerStatefulWidget {
  const MediaHandlerWidget0({
    required this.builder,
    required this.dbManager,
    required this.appSettings,
    super.key,
  });

  final DBManager dbManager;
  final AppSettings appSettings;
  final Widget Function({required MediaActions action})? builder;

  @override
  ConsumerState<MediaHandlerWidget0> createState() =>
      _MediaHandlerWidgetState();
}

class _MediaHandlerWidgetState extends ConsumerState<MediaHandlerWidget0> {
  @override
  Widget build(BuildContext context) {
    return widget.builder!(
      action: MediaActions(
        move: move,
        delete: delete,
        share: share,
        togglePin: togglePin,
        edit: edit,
        restoreDeleted: restoreDeleted,
        replaceMedia: replaceMedia,
        cloneAndReplaceMedia: cloneAndReplaceMedia,
        moveToCollectionStream: moveToCollectionStream,
        newMedia: newMedia,
        analyseMediaStream: analyseMediaStream,
        createTempFile: createTempFile,
        onUpsertNote: onUpsertNote,
        onDeleteNote: onDeleteNote,
      ),
    );
  }

  Future<bool> move(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }

    await MediaWizardService.addMedia(
      context,
      ref,
      media: CLSharedMedia(entries: selectedMedia, type: MediaSourceType.move),
    );
    if (mounted) {
      await context.push(
        '/media_wizard?type='
        '${MediaSourceType.move.name}',
      );
    }

    return true;
  }

  Future<bool> delete(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }
    if (selectedMedia.length == 1) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CLConfirmAction(
                title: 'Confirm delete',
                message: 'Are you sure you want to delete '
                    'this ${selectedMedia[0].type.name}?',
                child: PreviewService(media: selectedMedia[0]),
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
        await widget.dbManager.deleteMedia(
          selectedMedia[0],
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
                    '${selectedMedia.length} items?',
                child: null,
                onConfirm: ({required confirmed}) =>
                    Navigator.of(context).pop(confirmed),
              );
            },
          ) ??
          false;
      if (confirmed) {
        await widget.dbManager.deleteMediaMultiple(
          selectedMedia,
          onDeleteFile: (f) async => f.deleteIfExists(),
          onRemovePinMultiple: (id) async =>
              AlbumManagerHelper().removeMultipleMedia(context, ref, id),
        );
      }
      return confirmed;
    }
  }

  Future<bool> share(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }

    final box = context.findRenderObject() as RenderBox?;
    final files = selectedMedia.map((e) => XFile(e.path)).toList();
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

  Future<bool> edit(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }
    if (selectedMedia.length == 1) {
      if (selectedMedia[0].pin != null) {
        await ref.read(notificationMessageProvider.notifier).push(
              "Unpin to edit.\n Pinned items can't be edited",
            );
        return false;
      } else {
        // TODO(anandas):  Try moving this to app
        await context.push('/mediaEditor?id=${selectedMedia[0].id}');
        return true;
      }
    }
    return false;
  }

  Future<bool> togglePin(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }
    if (selectedMedia.length == 1) {
      await widget.dbManager.togglePin(
        selectedMedia[0],
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    } else {
      await widget.dbManager.pinMediaMultiple(
        selectedMedia,
        onPin: AlbumManagerHelper().albumManager.addMedia,
        onRemovePin: (id) async =>
            AlbumManagerHelper().removeMedia(context, ref, id),
      );
      return true;
    }
  }

  Future<bool> replaceMedia(List<CLMedia> selectedMedia, String outFile) {
    return save(selectedMedia, outFile, duplicate: false);
  }

  Future<bool> cloneAndReplaceMedia(
    List<CLMedia> selectedMedia,
    String outFile,
  ) {
    return save(selectedMedia, outFile, duplicate: true);
  }

  Future<bool> save(
    List<CLMedia> selectedMedia,
    String outFile, {
    required bool duplicate,
  }) async {
    final overwrite = !duplicate;
    if (selectedMedia.isEmpty) {
      return true;
    }
    if (selectedMedia.length == 1) {
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
                      type: selectedMedia[0].type,
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
        updatedMedia = selectedMedia[0]
            .copyWith(path: outFile, md5String: md5String)
            .removePin();
      } else {
        updatedMedia = CLMedia(
          path: outFile,
          md5String: md5String,
          type: selectedMedia[0].type,
          collectionId: selectedMedia[0].collectionId,
          originalDate: selectedMedia[0].originalDate,
          createdDate: selectedMedia[0].createdDate,
          isDeleted: selectedMedia[0].isDeleted,
          isHidden: selectedMedia[0].isHidden,
          updatedDate: selectedMedia[0].updatedDate,
        );
      }
      await widget.dbManager.upsertMedia(
        collectionId: selectedMedia[0].collectionId!,
        media: updatedMedia,
        onPrepareMedia: (m, {required targetDir}) async {
          final updated = await m.moveFile(targetDir: targetDir);

          return updated;
        },
      );
      if (overwrite) {
        await File(selectedMedia[0].path).deleteIfExists();
      }
    }
    return false;
  }

  //Can be converted to non static
  Stream<Progress> moveToCollectionStream(
    List<CLMedia> selectedMedia, {
    required Collection collection,
    required void Function() onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection = await widget.dbManager.upsertCollection(
        collection: collection,
      );
    } else {
      updatedCollection = collection;
    }

    if (selectedMedia.isNotEmpty) {
      final streamController = StreamController<Progress>();
      var completedMedia = 0;
      unawaited(
        widget.dbManager
            .upsertMediaMultiple(
          media: selectedMedia.map((e) => e.copyWith(isHidden: false)).toList(),
          collectionId: updatedCollection.id!,
          onPrepareMedia: (m, {required targetDir}) async {
            final updated =
                (await m.moveFile(targetDir: targetDir)).getMetadata();
            completedMedia++;

            streamController.add(
              Progress(
                fractCompleted: completedMedia / selectedMedia.length,
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

  Future<bool> restoreDeleted(List<CLMedia> selectedMedia) async {
    for (final item in selectedMedia) {
      if (item.id != null) {
        await widget.dbManager.upsertMedia(
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
  }

  Future<CLMedia?> newMedia(
    String path, {
    required bool isVideo,
    Collection? collection,
  }) async {
    final md5String = await File(path).checksum;
    CLMedia? media = CLMedia(
      path: path,
      type: isVideo ? CLMediaType.video : CLMediaType.image,
      collectionId: collection?.id,
      md5String: md5String,
    );

    if (collection == null) {
      final Collection tempCollection;
      tempCollection =
          await widget.dbManager.getCollectionByLabel(tempCollectionName) ??
              await widget.dbManager.upsertCollection(
                collection: const Collection(label: tempCollectionName),
              );
      media = await widget.dbManager.upsertMedia(
        collectionId: tempCollection.id!,
        media: media.copyWith(isHidden: true),
        onPrepareMedia: (m, {required targetDir}) async {
          final updated =
              (await m.moveFile(targetDir: targetDir)).getMetadata();
          return updated;
        },
      );
    } else {
      media = await widget.dbManager.upsertMedia(
        collectionId: collection.id!,
        media: media,
        onPrepareMedia: (m, {required targetDir}) async {
          final updated =
              (await m.moveFile(targetDir: targetDir)).getMetadata();
          return updated;
        },
      );
    }
    return media;
  }

  static const tempCollectionName = '*** Recently Captured';

  Stream<Progress> analyseMediaStream({
    required CLSharedMedia media,
    required void Function({
      required CLSharedMedia mg,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: path.basename(media.entries[0].path),
      fractCompleted: 0,
    );
    for (final (i, item0) in media.entries.indexed) {
      final item1 = await ExtDeviceProcessMedia.tryDownloadMedia(
        item0,
        appSettings: widget.appSettings,
      );
      final item = await ExtDeviceProcessMedia.identifyMediaType(
        item1,
        appSettings: widget.appSettings,
      );
      if (!item.type.isFile) {
        // Skip for now
      }
      if (item.type.isFile) {
        final file = File(item.path);
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await widget.dbManager.getMediaByMD5(md5String);
          if (duplicate != null) {
            candidates.add(duplicate);
          } else {
            final Collection tempCollection;
            tempCollection = await widget.dbManager
                    .getCollectionByLabel(tempCollectionName) ??
                await widget.dbManager.upsertCollection(
                  collection: const Collection(label: tempCollectionName),
                );
            final newMedia = CLMedia(
              path: item.path,
              type: item.type,
              collectionId: tempCollection.id,
              md5String: md5String,
              isHidden: true,
            );
            final tempMedia = await widget.dbManager.upsertMedia(
              collectionId: tempCollection.id!,
              media: newMedia.copyWith(isHidden: true),
              onPrepareMedia: (m, {required targetDir}) async {
                final updated =
                    (await m.moveFile(targetDir: targetDir)).getMetadata();
                return updated;
              },
            );
            if (tempMedia != null) {
              candidates.add(tempMedia);
            } else {
              /* Failed to add media, handle here */
            }
          }
        } else {
          /* Missing file? ignoring */
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 10));

      yield Progress(
        currentItem: (i + 1 == media.entries.length)
            ? ''
            : path.basename(media.entries[i + 1].path),
        fractCompleted: (i + 1) / media.entries.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    onDone(
      mg: CLSharedMedia(entries: candidates, collection: media.collection),
    );
  }

  Future<void> onUpsertNote(CLMedia media, CLNote note) async {
    await widget.dbManager.upsertNote(
      note,
      [media],
      onSaveNote: (note1, {required targetDir}) async {
        return note1.moveFile(targetDir: targetDir);
      },
    );
  }

  Future<void> onDeleteNote(CLNote note) async {
    if (note.id == null) return;
    await widget.dbManager.deleteNote(
      note,
      onDeleteFile: (file) async {
        await file.deleteIfExists();
      },
    );
  }

  Future<String> createTempFile({required String ext}) async {
    final dir = widget.appSettings.directories.downloadedMedia.path;
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }
}
