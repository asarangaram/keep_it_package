// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';
import 'package:uuid/uuid.dart';

extension ExtMetaData on CLMedia {
  Future<CLMedia> getMetadata({
    required Directory location,
    bool? regenerate,
  }) async {
    if (regenerate ?? true) {
      if (type == CLMediaType.image) {
        return copyWith(
          originalDate: (await File(path_handler.join(location.path, name))
                  .getImageMetaData())
              ?.originalDate,
        );
      } else if (type == CLMediaType.video) {
        return copyWith(
          originalDate: (await File(path_handler.join(location.path, name))
                  .getVideoMetaData())
              ?.originalDate,
        );
      } else {
        return this;
      }
    }
    return this;
  }
}

class StoreManagerView extends StatelessWidget {
  const StoreManagerView({
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
        return GetStoreManager(
          builder: (storeManger) {
            return MediaHandlerWidget0(
              storeManager: storeManger,
              storeInstance: storeManger.store,
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
    required this.storeManager,
    super.key,
  });

  final Store storeInstance;
  final AppSettings appSettings;
  final Widget child;
  final StoreManager storeManager;

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
      upsertNote: widget.storeManager.upsertNote,
      newMedia: widget.storeManager.newImageOrVideo,
      newMediaMultipleStream: widget.storeManager.analyseMediaStream,
      moveToCollectionStream: moveToCollectionStream,
      restoreMediaMultiple: restoreMediaMultiple,
      pinMediaMultiple: pinMediaMultiple,
      removePinMediaMultiple: removePinMediaMultiple,
      togglePinMultiple: togglePinMultiple,
      replaceMedia: widget.storeManager.replaceMedia,
      cloneAndReplaceMedia: widget.storeManager.cloneAndReplaceMedia,

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
      getNotesPath: getMediaPath,
      getText: getText,

      getMediaMultipleByIds: widget.storeManager.getMediaMultipleByIds,
    );
    return TheStore(
      storeAction: storeAction,
      child: widget.child,
    );
  }

  Future<bool> openWizard(
    BuildContext ctx,
    List<CLMedia> media,
    UniversalMediaSource wizardType, {
    Collection? collection,
  }) async {
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
        collection: collection,
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
      await File(
        path_handler.join(
          widget.appSettings.directories.media.pathString,
          m.name,
        ),
      ).deleteIfExists();
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
      mediaMultiple
          .map(
            (e) => path_handler.join(
              widget.appSettings.directories.media.pathString,
              e.name,
            ),
          )
          .toList(),
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
          path_handler.join(
            widget.appSettings.directories.media.pathString,
            media.name,
          ),
          title: media.name,
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
          currentItem: m.name,
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

  Future<void> deleteMedia(
    BuildContext ctx,
    CLMedia media, {
    bool permanent = false,
  }) async {
    if (media.id == null) return;

    await widget.storeInstance.deleteMedia(media, permanent: true);
    if (permanent) {
      await File(getMediaPath(media)).deleteIfExists();

      final orphanNotesQuery =
          widget.storeInstance.getQuery<CLMedia>(DBQueries.notesOrphan);

      final orphanNotes =
          await widget.storeInstance.readMultiple(orphanNotesQuery);
      if (orphanNotes.isNotEmpty) {
        for (final note in orphanNotes) {
          if (note != null) {
            await widget.storeInstance.deleteMedia(note, permanent: true);
            await File(getMediaPath(note)).deleteIfExists();
          }
        }
      }
    }
  }

  Future<void> onDeleteNote(BuildContext ctx, CLMedia note) async {
    await widget.storeInstance.deleteMedia(note, permanent: true);
  }

  Future<String> createTempFile({required String ext}) async {
    final dir = widget.appSettings.directories.download.path;
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
    final uuid = uuidGenerator.v5(Uuid.NAMESPACE_URL, media.name);
    final previewFileName = path_handler.join(
      widget.appSettings.directories.thumbnail.pathString,
      '$uuid.tn.jpeg',
    );
    return previewFileName;
  }

  String getMediaPath(CLMedia media) => path_handler.join(
        widget.appSettings.directories.media.path.path,
        media.name,
      );
  String getMediaLabel(CLMedia media) => media.name;

  String loadText(CLMedia? media) {
    if (media?.type != CLMediaType.text) return '';
    final path = getMediaPath(media!);

    return File(path).existsSync()
        ? File(path).readAsStringSync()
        : 'Content Missing. File not found';
  }

  String getText(CLMedia? note) => loadText(note);

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

    final mediaMultiple =
        await widget.storeManager.getMediaByCollectionId(collection.id!);

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

  static const uuidGenerator = Uuid();

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

  Future<void> reloadStore() async {
    await widget.storeInstance.reloadStore();
  }
}
