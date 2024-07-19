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
import 'package:path/path.dart' as path_handler;
import 'package:uuid/uuid.dart';

import 'dialogs.dart';

extension ExtMetaData on CLMedia {
  Future<CLMedia> getMetadata({
    required Directory location,
    bool? regenerate,
  }) async {
    if (type == CLMediaType.image) {
      return copyWith(
        originalDate: (await File(path_handler.join(location.path, label))
                .getImageMetaData(regenerate: regenerate))
            ?.originalDate,
      );
    } else if (type == CLMediaType.video) {
      return copyWith(
        originalDate: (await File(path_handler.join(location.path, label))
                .getVideoMetaData(regenerate: regenerate))
            ?.originalDate,
      );
    } else {
      return this;
    }
  }
}

class StoreManager extends StatelessWidget {
  const StoreManager({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      errorBuilder: (object, st) => const SizedBox.shrink(),
      loadingBuilder: () => const SizedBox.shrink(),
      builder: (appSettings) {
        return GetStore(
          builder: (storeInstance) {
            return MediaHandlerWidget0(
              storeInstance: storeInstance,
              appSettings: appSettings,
              child: child,
            );
          },
        );
      },
    );
  }
}

class MediaHandlerWidget0 extends ConsumerStatefulWidget {
  const MediaHandlerWidget0({
    required this.child,
    required this.storeInstance,
    required this.appSettings,
    super.key,
  });

  final Store storeInstance;
  final AppSettings appSettings;
  final Widget child;

  @override
  ConsumerState<MediaHandlerWidget0> createState() =>
      _MediaHandlerWidgetState();
}

class _MediaHandlerWidgetState extends ConsumerState<MediaHandlerWidget0> {
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  @override
  Widget build(BuildContext context) {
    final storeAction = StoreActions(
      upsertCollection: upsertCollection,
      upsertNote: upsertNote,
      newMedia: newMedia,
      newMediaMultipleStream: analyseMediaStream,
      moveToCollectionStream: moveToCollectionStream,
      restoreMediaMultiple: restoreMediaMultiple,
      pinMediaMultiple: pinMediaMultiple,
      removePinMediaMultiple: removePinMediaMultiple,
      togglePinMultiple: togglePinMultiple,
      replaceMedia: replaceMedia,
      cloneAndReplaceMedia: cloneAndReplaceMedia,

      deleteCollection: deleteCollection,
      deleteNote: onDeleteNote,
      deleteMediaMultiple: deleteMediaMultiple,
      permanentlyDeleteMediaMultiple: permanentlyDeleteMediaMultiple,

      /// Share modules
      shareMediaMultiple: shareMediaMultiple,
      shareFiles: ShareManager.onShareFiles,

      /// Open new screen
      openWizard: openWizard,
      openEditor: openEditor,
      openCamera: openCamera,
      openMedia: openMedia,
      openCollection: openCollection,

      createTempFile: createTempFile,
      createBackupFile: createBackupFile,

      reloadStore: reloadStore,
      getMediaPath: getMediaPath,
      getMediaLabel: getMediaLabel,
      getPreviewPath: getPreviewPath,
      getNotesPath: getNotesPath,
      getText: getText,
    );
    return TheStore(
      storeAction: storeAction,
      child: widget.child,
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

  Future<bool> openMoveWizard(List<CLMedia> mediaMultiple) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }

    await MediaWizardService.addMedia(
      context,
      ref,
      media: CLSharedMedia(
        entries: mediaMultiple,
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

  Future<bool> permanentlyDeleteMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }

    return await ConfirmAction.permanentlyDeleteMediaMultiple(
          context,
          media: mediaMultiple,
          onConfirm: () async {
            return permanentlyDeleteMediaMultipleAlreadyConfirmed(
              mediaMultiple,
            );
          },
          getPreview: (media) => PreviewService(
            media: media,
            keepAspectRatio: false,
          ),
        ) ??
        false;
  }

  Future<bool> permanentlyDeleteMediaMultipleAlreadyConfirmed(
    List<CLMedia> mediaMultiple,
  ) async {
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      mediaMultiple
          .map((e) => e.pin)
          .where((e) => e != null)
          .map((e) => e!)
          .toList(),
    );

    for (final m in mediaMultiple) {
      await widget.storeInstance.deleteMedia(m, permanent: true);
      await File(
        path_handler.join(
          widget.appSettings.directories.media.pathString,
          m.path,
        ),
      ).deleteIfExists();
    }
    final orphanNotes = await getOrphanNotes();
    if (orphanNotes != null) {
      for (final note in orphanNotes) {
        if (note != null) {
          await widget.storeInstance.deleteNote(note);
          await File(getNotesPath(note)).deleteIfExists();
        }
      }
    }
    return true;
  }

  Future<bool> deleteMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }

    return await ConfirmAction.deleteMediaMultiple(
          context,
          media: mediaMultiple,
          onConfirm: () async {
            return deleteMediaMultipleAlreadyConfirmed(
              mediaMultiple,
            );
          },
          getPreview: (media) => PreviewService(
            media: media,
            keepAspectRatio: false,
          ),
        ) ??
        false;

    // Remove Pins first..
  }

  Future<bool> deleteMediaMultipleAlreadyConfirmed(
    List<CLMedia> mediaMultiple,
  ) async {
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      mediaMultiple
          .map((e) => e.pin)
          .where((e) => e != null)
          .map((e) => e!)
          .toList(),
    );

    for (final m in mediaMultiple) {
      await widget.storeInstance.deleteMedia(m, permanent: false);
    }
    return true;
  }

  Future<bool> shareMediaMultiple(List<CLMedia> mediaMultiple) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      mediaMultiple
          .map(
            (e) => path_handler.join(
              widget.appSettings.directories.media.pathString,
              e.label,
            ),
          )
          .toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<bool> openEditor(
    List<CLMedia> mediaMultiple, {
    required bool canDuplicateMedia,
  }) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    if (mediaMultiple.length == 1) {
      if (mediaMultiple[0].pin != null) {
        await ref.read(notificationMessageProvider.notifier).push(
              "Unpin to edit.\n Pinned items can't be edited",
            );
        return false;
      } else {
        await context.push(
          '/mediaEditor?id=${mediaMultiple[0].id}&canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> togglePinMultiple(List<CLMedia> mediaMultiple) async {
    if (mediaMultiple.any((e) => e.pin == null)) {
      return pinMediaMultiple(mediaMultiple);
    } else {
      return removePinMediaMultiple(mediaMultiple);
    }
  }

  Future<bool> removePinMediaMultiple(List<CLMedia> mediaMultiple) async {
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    final res = await removeMultipleMediaFromGallery(
      pinnedMedia.map((e) => e.pin!).toList(),
    );
    if (res) {
      await upsertMediaMultiple(pinnedMedia.map((e) => e.removePin()).toList());
    }
    return res;
  }

  Future<bool> pinMediaMultiple(List<CLMedia> mediaMultiple) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLMedia>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final pin = await albumManager.addMedia(
          path_handler.join(
            widget.appSettings.directories.media.pathString,
            media.label,
          ),
          title: media.path,
          isImage: media.type == CLMediaType.image,
          isVideo: media.type == CLMediaType.video,
          desc: 'KeepIT',
        );
        if (pin != null) {
          updatedMedia.add(media.copyWith(pin: pin));
        }
      }
    }
    await upsertMediaMultiple(updatedMedia);
    return true;
  }

  Future<bool> replaceMedia(CLMedia originalMedia, String outFile) async {
    final savedFile =
        File(outFile).copyTo(widget.appSettings.directories.media.path);

    final md5String = await savedFile.checksum;
    final updatedMedia = originalMedia
        .copyWith(
          path: path_handler.basename(savedFile.path),
          md5String: md5String,
        )
        .removePin();
    if (mounted) {
      final success = await ConfirmAction.replaceMedia(
            context,
            media: updatedMedia,
            getPreview: (CLMedia media) => PreviewService(
              media: media,
              keepAspectRatio: false,
            ),
            onConfirm: () async {
              final mediaFromDB = await widget.storeInstance.upsertMedia(
                updatedMedia,
              );
              if (mediaFromDB != null) {
                await File(
                  path_handler.join(
                    widget.appSettings.directories.media.pathString,
                    originalMedia.label,
                  ),
                ).deleteIfExists();
              }
              return mediaFromDB != null;
            },
          ) ??
          false;
      if (!success) {
        await File(
          path_handler.join(
            widget.appSettings.directories.media.pathString,
            updatedMedia.label,
          ),
        ).deleteIfExists();
      }
      return success;
    }

    return false;
  }

  Future<bool> cloneAndReplaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final savedFile =
        File(outFile).copyTo(widget.appSettings.directories.media.path);

    final md5String = await savedFile.checksum;
    final CLMedia updatedMedia;
    updatedMedia = originalMedia
        .copyWith(
          path: path_handler.basename(savedFile.path),
          md5String: md5String,
        )
        .removePin();
    if (mounted) {
      final success = await ConfirmAction.cloneAndReplaceMedia(
            context,
            media: updatedMedia,
            getPreview: (CLMedia media) => PreviewService(
              media: media,
              keepAspectRatio: false,
            ),
            onConfirm: () async {
              final mediaFromDB = await widget.storeInstance.upsertMedia(
                updatedMedia.removeId(),
              );

              return mediaFromDB != null;
            },
          ) ??
          false;
      if (!success) {
        await File(
          path_handler.join(
            widget.appSettings.directories.media.pathString,
            updatedMedia.label,
          ),
        ).deleteIfExists();
      }
      return success;
    }

    return false;
  }

  //Can be converted to non static
  Stream<Progress> moveToCollectionStream(
    List<CLMedia> mediaMultiple, {
    required Collection collection,
    required void Function() onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection =
          await widget.storeInstance.upsertCollection(collection);
    } else {
      updatedCollection = collection;
    }

    if (mediaMultiple.isNotEmpty) {
      final streamController = StreamController<Progress>();

      unawaited(
        upsertMediaMultiple(
          mediaMultiple
              .map(
                (e) => e.copyWith(
                  isHidden: false,
                  collectionId: updatedCollection.id,
                ),
              )
              .toList(),
          onProgress: (progress) async {
            streamController.add(progress);
            await Future<void>.delayed(const Duration(microseconds: 1));
          },
        ).then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Successfully Imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 1));
          await streamController.close();
          onDone();
        }),
      );
      yield* streamController.stream;
    }
  }

  Future<void> upsertMediaMultiple(
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    for (final (i, m) in mediaMultiple.indexed) {
      await widget.storeInstance.upsertMedia(m);
      onProgress?.call(
        Progress(
          fractCompleted: i / mediaMultiple.length,
          currentItem: m.label,
        ),
      );
    }
  }

  Future<bool> restoreMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    final bool confirmed;

    confirmed = await ConfirmAction.restoreMediaMultiple(
          context,
          media: mediaMultiple,
          onConfirm: () async {
            return true;
          },
          getPreview: (media) => PreviewService(
            media: media,
            keepAspectRatio: false,
          ),
        ) ??
        false;

    if (!confirmed) {
      return confirmed;
    }

    for (final item in mediaMultiple) {
      if (item.id != null) {
        await widget.storeInstance.upsertMedia(item.copyWith(isDeleted: false));
      }
    }
    return true;
  }

  Future<CLMedia?> newMedia(
    String fileName, {
    required bool isVideo,
    Collection? collection,
  }) async {
    // Get Collection if required
    Collection collection0;
    if (collection == null) {
      collection0 = await getCollectionByLabel(tempCollectionName) ??
          await widget.storeInstance.upsertCollection(
            const Collection(label: tempCollectionName),
          );
    } else {
      collection0 = collection;
    }

    final savedMediaFile =
        File(fileName).copyTo(widget.appSettings.directories.media.path);

    final md5String = await File(fileName).checksum;
    final savedMedia = CLMedia(
      path: path_handler.basename(savedMediaFile.path),
      type: isVideo ? CLMediaType.video : CLMediaType.image,
      collectionId: collection0.id,
      md5String: md5String,
      isHidden: collection == null,
    );
    final mediaFromDB = await widget.storeInstance.upsertMedia(savedMedia);
    if (mediaFromDB == null) {
      await File(
        path_handler.join(
          widget.appSettings.directories.media.pathString,
          savedMedia.label,
        ),
      ).deleteIfExists();
    } else {
      await File(fileName).deleteIfExists();
    }
    return mediaFromDB;
  }

  static const tempCollectionName = '*** Recently Captured';

  Stream<Progress> analyseMediaStream({
    required List<CLMediaFile> mediaFiles,
    required void Function({
      required List<CLMedia> mediaMultiple,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: path_handler.basename(mediaFiles[0].path),
      fractCompleted: 0,
    );
    for (final (i, item0) in mediaFiles.indexed) {
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
        final file = File(
          item.path,
        );
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await getMediaByMD5(md5String);
          if (duplicate != null) {
            candidates.add(duplicate);
          } else {
            final Collection tempCollection;
            tempCollection = await getCollectionByLabel(tempCollectionName) ??
                await widget.storeInstance.upsertCollection(
                  const Collection(label: tempCollectionName),
                );

            /// Approach
            /// 1. First copy the content to media directory
            ///   1a. Adjust file name if similar item is found
            /// 2. Try updating the data base
            /// 3a. If failed, delete the copy created
            /// 3b. If succeed,
            ///     delete the original file (if it is mobile platform)

            final savedMediaFile = File(
              item.path,
            ).copyTo(widget.appSettings.directories.media.path);

            final savedMedia = await CLMedia(
              path: path_handler.basename(savedMediaFile.path),
              type: item.type,
              collectionId: tempCollection.id,
              md5String: md5String,
              isHidden: true,
            ).getMetadata(location: widget.appSettings.directories.media.path);

            final mediaFromDB =
                await widget.storeInstance.upsertMedia(savedMedia);
            if (mediaFromDB != null) {
              candidates.add(mediaFromDB);
            } else {
              /* Failed to add media, handle here */
            }
          }
        } else {
          /* Missing file? ignoring */
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));

      yield Progress(
        currentItem: (i + 1 == mediaFiles.length)
            ? ''
            : path_handler.basename(
                mediaFiles[i + 1].path,
              ),
        fractCompleted: (i + 1) / mediaFiles.length,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 1));
    onDone(
      mediaMultiple: candidates,
    );
  }

  Future<void> upsertNote(
    String path,
    CLNoteTypes type, {
    required List<CLMedia> mediaMultiple,
    CLNote? note,
  }) async {
    final savedNotesFile =
        File(path).copyTo(widget.appSettings.directories.notes.path);

    final savedNotes = note?.copyWith(
          path: path_handler.basename(savedNotesFile.path),
          type: type,
        ) ??
        CLNote(
          createdDate: DateTime.now(),
          type: type,
          path: path_handler.basename(savedNotesFile.path),
          id: null,
        );

    final notesInDB = await widget.storeInstance.upsertNote(
      savedNotes,
      mediaMultiple,
    );
    if (notesInDB == null) {
      await savedNotesFile.delete();
    } else {
      await File(path).deleteIfExists();
      if (note != null) {
        // delete the older notes
        await File(getNotesPath(note)).deleteIfExists();
      }
    }
  }

  Future<void> onDeleteNote(CLNote note) async {
    if (note.id == null) return;
    final bool confirmed;
    if (note.type == CLNoteTypes.text) {
      confirmed = await ConfirmAction.deleteNote(
            context,
            note: note,
            onConfirm: () async {
              return true;
            },
          ) ??
          false;
    } else {
      confirmed = true;
    }

    if (!confirmed) {
      return;
    }

    await widget.storeInstance.deleteNote(note);
    await File(getNotesPath(note)).deleteIfExists();
  }

  Future<String> createTempFile({required String ext}) async {
    final dir = widget.appSettings.directories.downloadedMedia.path;
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }

  Future<String> createBackupFile() async {
    final dir = widget.appSettings.directories.backup.path;
    final fileBasename =
        'keep_it_backup_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.tar.gz';

    return absolutePath;
  }

  String getPreviewPath(CLMedia media) {
    final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, media.label);
    final previewFileName = path_handler.join(
      widget.appSettings.directories.thumbnail.pathString,
      '$uuid.tn.jpeg',
    );
    return previewFileName;
  }

  String getMediaPath(CLMedia media) => path_handler.join(
        widget.appSettings.directories.media.path.path,
        media.label,
      );
  String getMediaLabel(CLMedia media) => media.label;

  String getNotesPath(CLNote note) => path_handler.join(
        widget.appSettings.directories.notes.path.path,
        note.path,
      );

  String getText(CLTextNote? note) {
    final String text;
    if (note != null) {
      final notesPath = getNotesPath(note);

      final notesFile = File(notesPath);
      if (!notesFile.existsSync()) {
        text = 'Content Missing. File is deleted';
      } else {
        text = notesFile.readAsStringSync();
      }
    } else {
      text = '';
    }
    return text;
  }

  Future<Collection> upsertCollection(Collection collection) async {
    final updated = await widget.storeInstance.upsertCollection(collection);
    await ref.read(notificationMessageProvider.notifier).push('Updated');
    return updated;
  }

  Future<bool> deleteCollection(
    Collection collection,
  ) async {
    return await ConfirmAction.deleteCollection(
          context,
          collection: collection,
          onConfirm: () async => deleteCollectionAlreadyConfirmed(collection),
        ) ??
        false;
  }

  Future<bool> deleteCollectionAlreadyConfirmed(Collection collection) async {
    if (collection.id == null) return true;

    final mediaMultiple = await getMediaByCollectionId(collection.id!);

    /// Delete all media ignoring those already in Recycle
    /// Don't delete CollectionDir / Collection from Media, required for restore

    await deleteMediaMultipleAlreadyConfirmed(
      mediaMultiple.where((e) => e != null).map((e) => e!).toList(),
    );
    return true;
  }

  final uuidGenerator = const Uuid();

  static Future<CLMediaFile> tryDownloadMedia(
    CLMediaFile mediaFile, {
    required AppSettings appSettings,
  }) async {
    if (mediaFile.type != CLMediaType.url) {
      return mediaFile;
    }
    final mimeType = await URLHandler.getMimeType(
      mediaFile.path,
    );
    if (![
      CLMediaType.image,
      CLMediaType.video,
      CLMediaType.audio,
      CLMediaType.file,
    ].contains(mimeType)) {
      return mediaFile;
    }
    final downloadedFile = await URLHandler.download(
      mediaFile.path,
      appSettings.directories.downloadedMedia.path,
    );
    if (downloadedFile == null) {
      return mediaFile;
    }
    return mediaFile.copyWith(path: downloadedFile, type: mimeType);
  }

  static Future<CLMediaFile> identifyMediaType(
    CLMediaFile mediaFile, {
    required AppSettings appSettings,
  }) async {
    if (mediaFile.type != CLMediaType.file) {
      return mediaFile;
    }

    final mimeType = switch (lookupMimeType(mediaFile.path)) {
      (final String mime) when mime.startsWith('image') => CLMediaType.image,
      (final String mime) when mime.startsWith('video') => CLMediaType.video,
      _ => CLMediaType.file
    };
    if (mimeType == CLMediaType.file) {
      return mediaFile;
    }
    return mediaFile.copyWith(type: mimeType);
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

  Future<List<CLMedia?>> getMediaByCollectionId(
    int collectionId,
  ) {
    final q = widget.storeInstance.getQuery(
      DBQueries.mediaByCollectionId,
      parameters: [collectionId],
    ) as StoreQuery<CLMedia>;
    return widget.storeInstance.readMultiple(q);
  }

  Future<Collection?> getCollectionByLabel(
    String label,
  ) async {
    final q = widget.storeInstance.getQuery(
      DBQueries.collectionByLabel,
      parameters: [label],
    ) as StoreQuery<Collection>;
    return widget.storeInstance.read(q);
  }

  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async {
    final q = widget.storeInstance.getQuery(
      DBQueries.mediaByMD5,
      parameters: [md5String],
    ) as StoreQuery<CLMedia>;
    return widget.storeInstance.read(q);
  }

  Future<List<CLNote?>?> getOrphanNotes() {
    final q = widget.storeInstance.getQuery(DBQueries.notesOrphan)
        as StoreQuery<CLNote>;
    return widget.storeInstance.readMultiple(q);
  }

  Future<void> reloadStore() async {
    await widget.storeInstance.reloadStore();
  }
}
