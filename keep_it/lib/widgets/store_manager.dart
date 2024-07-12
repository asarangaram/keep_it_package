// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'package:store/store.dart';
import 'package:uuid/uuid.dart';

extension ExtMetaData on CLMedia {
  Future<CLMedia> getMetadata({bool? regenerate}) async {
    if (type == CLMediaType.image) {
      return copyWith(
        originalDate:
            (await File(this.path).getImageMetaData(regenerate: regenerate))
                ?.originalDate,
      );
    } else if (type == CLMediaType.video) {
      return copyWith(
        originalDate:
            (await File(this.path).getVideoMetaData(regenerate: regenerate))
                ?.originalDate,
      );
    } else {
      return this;
    }
  }
}

class StoreManager extends StatelessWidget {
  const StoreManager({
    required this.builder,
    super.key,
  });

  final Widget Function({required StoreActions storeAction})? builder;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      errorBuilder: (object, st) => const SizedBox.shrink(),
      loadingBuilder: () => const SizedBox.shrink(),
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
  final Widget Function({required StoreActions storeAction})? builder;

  @override
  ConsumerState<MediaHandlerWidget0> createState() =>
      _MediaHandlerWidgetState();
}

class _MediaHandlerWidgetState extends ConsumerState<MediaHandlerWidget0> {
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  @override
  Widget build(BuildContext context) {
    return widget.builder!(
      storeAction: StoreActions(
        openWizard: openWizard,
        delete: delete,
        share: share,
        togglePin: togglePin,
        openEditor: openEditor,
        restoreDeleted: restoreDeleted,
        replaceMedia: replaceMedia,
        cloneAndReplaceMedia: cloneAndReplaceMedia,
        moveToCollectionStream: moveToCollectionStream,
        newMedia: newMedia,
        analyseMediaStream: analyseMediaStream,
        createTempFile: createTempFile,
        onUpsertNote: onUpsertNote,
        onDeleteNote: onDeleteNote,
        getPreviewPath: getPreviewPath,
        upsertCollection: upsertCollection,
        deleteCollection: deleteCollection,
        openCamera: openCamera,
        openMedia: openMedia,
        openCollection: openCollection,
        onShareFiles: ShareManager.onShareFiles,
      ),
    );
  }

  Future<bool> openWizard(
    List<CLMedia> media,
    UniversalMediaSource wizardType,
  ) async {
    if (media.isEmpty) {
      await ref
          .read(notificationMessageProvider.notifier)
          .push('Nothing to do.');
      return true;
    }

    await MediaWizardService.addMedia(
      context,
      ref,
      media: CLSharedMedia(
        entries: media,
        type: wizardType,
      ),
    );
    if (mounted) {
      await context.push(
        '/media_wizard?type='
        '${wizardType.name}',
      );
    }

    return true;
  }

  Future<bool> openMoveWizard(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }

    await MediaWizardService.addMedia(
      context,
      ref,
      media: CLSharedMedia(
        entries: selectedMedia,
        type: UniversalMediaSource.move,
      ),
    );
    if (mounted) {
      await context.push(
        '/media_wizard?type='
        '${UniversalMediaSource.move.name}',
      );
    }

    return true;
  }

  Future<bool> delete(
    List<CLMedia> selectedMedia, {
    required bool? confirmed,
  }) async {
    if (confirmed == null || !confirmed) {
      return false;
    }
    if (selectedMedia.isEmpty) {
      return true;
    }
    if (selectedMedia.length == 1) {
      await widget.dbManager.deleteMedia(
        selectedMedia[0],
        onDeleteFile: (f) async => f.deleteIfExists(),
        onRemovePin: (id) async => removeMediaFromGallery(id),
      );
    } else {
      await widget.dbManager.deleteMediaMultiple(
        selectedMedia,
        onDeleteFile: (f) async => f.deleteIfExists(),
        onRemovePinMultiple: (id) async => removeMultipleMediaFromGallery(id),
      );
    }
    return true;
  }

  Future<bool> share(List<CLMedia> selectedMedia) async {
    if (selectedMedia.isEmpty) {
      return true;
    }
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      selectedMedia.map((e) => e.path).toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<bool> openEditor(
    List<CLMedia> selectedMedia, {
    required bool canDuplicateMedia,
  }) async {
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
        await context.push(
          '/mediaEditor?id=${selectedMedia[0].id}&canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
        );
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
        onPin: (media, {required title, desc}) {
          return albumManager.addMedia(
            media.path,
            title: title,
            isImage: media.type == CLMediaType.image,
            isVideo: media.type == CLMediaType.video,
            desc: desc,
          );
        },
        onRemovePin: (id) async => removeMediaFromGallery(id),
      );
      return true;
    } else {
      await widget.dbManager.pinMediaMultiple(
        selectedMedia,
        onPin: (media, {required title, desc}) {
          return albumManager.addMedia(
            media.path,
            title: title,
            isImage: media.type == CLMediaType.image,
            isVideo: media.type == CLMediaType.video,
            desc: desc,
          );
        },
        onRemovePin: (id) async => removeMediaFromGallery(id),
      );
      return true;
    }
  }

  Future<bool> replaceMedia(
    List<CLMedia> selectedMedia,
    String outFile, {
    required bool? confirmed,
  }) {
    return save(selectedMedia, outFile, duplicate: false, confirmed: confirmed);
  }

  Future<bool> cloneAndReplaceMedia(
    List<CLMedia> selectedMedia,
    String outFile, {
    required bool? confirmed,
  }) {
    return save(selectedMedia, outFile, duplicate: true, confirmed: confirmed);
  }

  Future<bool> save(
    List<CLMedia> selectedMedia,
    String outFile, {
    required bool duplicate,
    required bool? confirmed,
  }) async {
    if (confirmed == null || !confirmed) return false;

    if (selectedMedia.isEmpty) {
      return true;
    }
    final overwrite = !duplicate;
    if (selectedMedia.length == 1) {
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
    return true;
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

  Future<bool> restoreDeleted(
    List<CLMedia> selectedMedia, {
    required bool? confirmed,
  }) async {
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
    required List<CLMedia> media,
    required void Function({
      required List<CLMedia> mg,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: path.basename(media[0].path),
      fractCompleted: 0,
    );
    for (final (i, item0) in media.indexed) {
      final item1 = await tryDownloadMedia(
        item0,
        appSettings: widget.appSettings,
      );
      final item = await identifyMediaType(
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
        currentItem:
            (i + 1 == media.length) ? '' : path.basename(media[i + 1].path),
        fractCompleted: (i + 1) / media.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    onDone(
      mg: candidates,
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

  Future<void> onDeleteNote(
    CLNote note, {
    required bool? confirmed,
  }) async {
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

  String getPreviewPath(CLMedia media) {
    final relativePath = CLMedia.relativePath(
      media.path,
      pathPrefix: widget.appSettings.directories.media.pathString,
      validate: false,
    );

    final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, relativePath);
    final previewFileName = path.join(
      widget.appSettings.directories.thumbnail.pathString,
      '$uuid.tn.jpeg',
    );
    return previewFileName;
  }

  Future<Collection> upsertCollection(Collection collection) async {
    final updated = await widget.dbManager.upsertCollection(
      collection: collection,
    );
    await ref.read(notificationMessageProvider.notifier).push('Updated');
    return updated;
  }

  Future<bool> deleteCollection(
    Collection collection, {
    required bool? confirmed,
  }) async {
    await widget.dbManager.deleteCollection(
      collection,
      onDeleteFile: (file) async {
        if (file.existsSync()) {
          file.deleteSync();
        }
      },
    );
    return true;
  }

  final uuidGenerator = const Uuid();

  static Future<CLMedia> tryDownloadMedia(
    CLMedia item0, {
    required AppSettings appSettings,
  }) async {
    if (item0.type != CLMediaType.url) {
      return item0;
    }
    final mimeType = await URLHandler.getMimeType(item0.path);
    if (![
      CLMediaType.image,
      CLMediaType.video,
      CLMediaType.audio,
      CLMediaType.file,
    ].contains(mimeType)) {
      return item0;
    }
    final downloadedFile = await URLHandler.download(
      item0.path,
      appSettings.directories.downloadedMedia.path,
    );
    if (downloadedFile == null) {
      return item0;
    }
    return item0.copyWith(path: downloadedFile, type: mimeType);
  }

  static Future<CLMedia> identifyMediaType(
    CLMedia item0, {
    required AppSettings appSettings,
  }) async {
    if (item0.type != CLMediaType.file) {
      return item0;
    }
    final mimeType = switch (lookupMimeType(item0.path)) {
      (final String mime) when mime.startsWith('image') => CLMediaType.image,
      (final String mime) when mime.startsWith('video') => CLMediaType.video,
      _ => CLMediaType.file
    };
    if (mimeType == CLMediaType.file) {
      return item0;
    }
    return item0.copyWith(type: mimeType);
  }

  Future<bool> removeMediaFromGallery(
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);
    if (!res) {
      if (context.mounted) {
        await ref
            .read(
              notificationMessageProvider.notifier,
            )
            .push(
              'Failed: Did you give permission to remove from Gallery?',
            );
      }
    }
    return res;
  }

  Future<bool> removeMultipleMediaFromGallery(
    List<String> ids,
  ) async {
    final res = await albumManager.removeMultipleMedia(ids);
    if (!res) {
      if (context.mounted) {
        await ref
            .read(
              notificationMessageProvider.notifier,
            )
            .push(
              'Failed: Did you give permission to remove from Gallery?',
            );
      }
    }
    return res;
  }

  Future<void> openCamera({int? collectionId}) async {
    await CLCameraService.invokeWithSufficientPermission(
      context,
      () async {
        if (context.mounted) {
          await context.push(
            '/camera'
            '${collectionId == null ? '' : '?collectionId=$collectionId'}',
          );
        }
      },
      themeData: DefaultCLCameraIcons(),
    );
  }

  Future<void> openMedia(
    int mediaId, {
    required ActionControl actionControl,
    int? collectionId,
    String? parentIdentifier,
  }) async {
    final queryMap = [
      if (parentIdentifier != null) 'parentIdentifier="$parentIdentifier"',
      if (collectionId != null) 'collectionId=$collectionId',
      // ignore: unnecessary_null_comparison
      if (actionControl != null) 'actionControl=${actionControl.toJson()}',
    ];
    final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';

    await context.push('/media/$mediaId$query');
  }

  Future<void> openCollection({
    int? collectionId,
  }) async {
    await context.push(
      '/items_by_collection/$collectionId',
    );
  }
}
