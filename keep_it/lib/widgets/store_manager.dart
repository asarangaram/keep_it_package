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

import '../models/file_system_manager.dart';

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
              fsManager: FileSystemManager(appSettings),
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
    required this.fsManager,
    super.key,
  });

  final Store storeInstance;
  final AppSettings appSettings;
  final Widget child;
  final FileSystemManager fsManager;

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

      createTempFile: widget.fsManager.createTempFile,
      createBackupFile: widget.fsManager.createBackupFile,

      reloadStore: reloadStore,
      getMediaPath: widget.fsManager.getMediaPath,
      getMediaLabel: widget.fsManager.getMediaLabel,
      getPreviewPath: widget.fsManager.getPreviewPath,
      getNotesPath: widget.fsManager.getNotesPath,
      getText: widget.fsManager.getText,

      getMediaMultipleByIds: getMediaMultipleByIds,
    );
    return TheStore(
      storeAction: storeAction,
      child: widget.child,
    );
  }

  Future<bool> openWizard(
    BuildContext ctx,
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
    if (ctx.mounted) {
      await ctx.push(
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
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      ctx,
      pinnedMedia.map((e) => e.pin!).toList(),
    );

    for (final m in mediaMultiple) {
      await widget.storeInstance.deleteMedia(m, permanent: true);
      await widget.fsManager.deleteMediaFiles(m);
    }
    final orphanNotes = await getOrphanNotes();
    if (orphanNotes != null) {
      for (final note in orphanNotes) {
        if (note != null) {
          await widget.storeInstance.deleteNote(note);
          await widget.fsManager.deleteNoteFiles(note);
        }
      }
    }
    return true;
  }

  Future<bool> deleteMediaMultiple(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    // Remove Pins first..
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    // Remove Pins first..
    await removeMultipleMediaFromGallery(
      ctx,
      pinnedMedia.map((e) => e.pin!).toList(),
    );

    for (final m in mediaMultiple) {
      await widget.storeInstance.deleteMedia(m, permanent: false);
    }
    return true;
  }

  Future<bool> shareMediaMultiple(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final box = ctx.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      ctx,
      mediaMultiple.map((e) => widget.fsManager.getMediaPath(e)).toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<CLMedia> openEditor(
    BuildContext ctx,
    CLMedia media, {
    required bool canDuplicateMedia,
  }) async {
    if (media.pin != null) {
      await ref.read(notificationMessageProvider.notifier).push(
            "Unpin to edit.\n Pinned items can't be edited",
          );
      return media;
    } else {
      final edittedMedia = await ctx.push<CLMedia>(
        '/mediaEditor?id=${media.id}&canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
      );
      return edittedMedia ?? media;
    }
  }

  Future<bool> togglePinMultiple(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.any((e) => e.pin == null)) {
      return pinMediaMultiple(context, mediaMultiple);
    } else {
      return removePinMediaMultiple(ctx, mediaMultiple);
    }
  }

  Future<bool> removePinMediaMultiple(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    final res = await removeMultipleMediaFromGallery(
      ctx,
      pinnedMedia.map((e) => e.pin!).toList(),
    );
    if (res) {
      await upsertMediaMultiple(pinnedMedia.map((e) => e.removePin()).toList());
    }
    return res;
  }

  Future<bool> pinMediaMultiple(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLMedia>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final pin = await albumManager.addMedia(
          widget.fsManager.getMediaPath(media),
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

  Future<CLMedia> replaceMedia(
    BuildContext ctx,
    CLMedia originalMedia,
    String outFile,
  ) async {
    final savedFile =
        File(outFile).copyTo(widget.appSettings.directories.media.path);

    final md5String = await savedFile.checksum;
    final updatedMedia = originalMedia
        .copyWith(
          path: savedFile.basename,
          md5String: md5String,
        )
        .removePin();

    final mediaFromDB = await widget.storeInstance.upsertMedia(
      updatedMedia,
    );
    if (mediaFromDB != null) {
      await widget.fsManager.deleteMediaFiles(originalMedia);
    } else {
      await widget.fsManager.deleteMediaFiles(updatedMedia);
    }

    return mediaFromDB ?? originalMedia;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    BuildContext ctx,
    CLMedia originalMedia,
    String outFile,
  ) async {
    final savedFile =
        File(outFile).copyTo(widget.appSettings.directories.media.path);

    final md5String = await savedFile.checksum;
    final CLMedia updatedMedia;
    updatedMedia = originalMedia
        .copyWith(
          path: savedFile.basename,
          md5String: md5String,
        )
        .removePin();

    final mediaFromDB = await widget.storeInstance.upsertMedia(
      updatedMedia.removeId(),
    );

    return mediaFromDB ?? originalMedia;
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
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
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

    final savedFile =
        File(fileName).moveTo(widget.appSettings.directories.media.path);

    final md5String = await File(fileName).checksum;
    final savedMedia = CLMedia(
      path: savedFile.basename,
      type: isVideo ? CLMediaType.video : CLMediaType.image,
      collectionId: collection0.id,
      md5String: md5String,
      isHidden: collection == null,
    );
    final mediaFromDB = await widget.storeInstance.upsertMedia(savedMedia);
    if (mediaFromDB == null) {
      await widget.fsManager.deleteMediaFiles(savedMedia);
    } else {}
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
      currentItem: mediaFiles[0].basename,
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

            final savedFile = File(
              item.path,
            ).copyTo(widget.appSettings.directories.media.path);

            final savedMedia = await widget.fsManager.getMetadata(
              CLMedia(
                path: savedFile.basename,
                type: item.type,
                collectionId: tempCollection.id,
                md5String: md5String,
                isHidden: true,
              ),
            );

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
        currentItem:
            (i + 1 == mediaFiles.length) ? '' : mediaFiles[i + 1].basename,
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
    CLNote? originalNote,
  }) async {
    final savedNotesFile =
        File(path).moveTo(widget.appSettings.directories.notes.path);

    final savedNotes = originalNote?.copyWith(
          path: savedNotesFile.basename,
          type: type,
        ) ??
        CLNote(
          createdDate: DateTime.now(),
          type: type,
          path: savedNotesFile.basename,
          id: null,
        );

    final notesInDB = await widget.storeInstance.upsertNote(
      savedNotes,
      mediaMultiple,
    );
    if (notesInDB == null) {
      await savedNotesFile.delete();
    } else {
      if (originalNote != null) {
        await widget.fsManager.deleteNoteFiles(originalNote);
      }
    }
  }

  Future<void> onDeleteNote(BuildContext ctx, CLNote note) async {
    if (note.id == null) return;

    await widget.storeInstance.deleteNote(note);
    await widget.fsManager.deleteNoteFiles(note);
  }

  Future<Collection> upsertCollection(Collection collection) async {
    final updated = await widget.storeInstance.upsertCollection(collection);
    await ref.read(notificationMessageProvider.notifier).push('Updated');
    return updated;
  }

  Future<bool> deleteCollection(
    BuildContext ctx,
    Collection collection,
  ) async {
    if (collection.id == null) return true;

    final mediaMultiple = await getMediaByCollectionId(collection.id!);

    /// Delete all media ignoring those already in Recycle
    /// Don't delete CollectionDir / Collection from Media, required for restore
    if (ctx.mounted) {
      await deleteMediaMultiple(
        ctx,
        mediaMultiple.where((e) => e != null).map((e) => e!).toList(),
      );
      return true;
    }
    return false;
  }

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
    BuildContext ctx,
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);
    if (!res) {
      if (ctx.mounted) {
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
    BuildContext ctx,
    List<String> ids,
  ) async {
    if (ids.isEmpty) return true;
    final res = await albumManager.removeMultipleMedia(ids);
    if (!res) {
      if (ctx.mounted) {
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

  Future<void> openCamera(BuildContext ctx, {int? collectionId}) async {
    await CLCameraService.invokeWithSufficientPermission(
      ctx,
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

  Future<void> openCollection(
    BuildContext ctx, {
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

  Future<List<CLMedia?>> getMediaMultipleByIds(
    List<int> idList,
  ) {
    final q = widget.storeInstance.getQuery(
      DBQueries.mediaByIdList,
      parameters: ['(${idList.join(', ')})'],
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
