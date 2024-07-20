// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/file_system_manager.dart';
import '../models/media_handler.dart';

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
        final fsManager = FileSystemManager(appSettings);
        return GetStore(
          builder: (storeInstance) {
            return MediaHandlerWidget0(
              storeInstance: storeInstance,
              fsManager: fsManager,
              mediaHandeler: MediaHandler(
                fsManager: fsManager,
                store: storeInstance,
                albumManager: AlbumManager(albumName: 'KeepIt'),
              ),
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
    required this.fsManager,
    required this.mediaHandeler,
    super.key,
  });
  final MediaHandler mediaHandeler;
  final Store storeInstance;

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
      upsertCollection: widget.mediaHandeler.upsertCollection,
      upsertNote: widget.mediaHandeler.upsertNote,
      newMedia: widget.mediaHandeler.newMedia,
      newMediaMultipleStream: widget.mediaHandeler.newMediaMultipleStream,
      moveToCollectionStream: widget.mediaHandeler.moveToCollectionStream,
      restoreMediaMultiple: widget.mediaHandeler.restoreMediaMultiple,
      pinMediaMultiple: widget.mediaHandeler.pinMediaMultiple,
      removePinMediaMultiple: widget.mediaHandeler.removePinMediaMultiple,
      togglePinMultiple: widget.mediaHandeler.togglePinMultiple,
      replaceMedia: widget.mediaHandeler.replaceMedia,
      cloneAndReplaceMedia: widget.mediaHandeler.cloneAndReplaceMedia,

      deleteCollection: widget.mediaHandeler.deleteCollection,
      deleteNote: widget.mediaHandeler.onDeleteNote,
      deleteMediaMultiple: widget.mediaHandeler.deleteMediaMultiple,
      permanentlyDeleteMediaMultiple:
          widget.mediaHandeler.permanentlyDeleteMediaMultiple,

      /// Share modules
      shareMediaMultiple: shareMediaMultiple,
      shareFiles: ShareManager.onShareFiles,

      /// Open new screen
      openWizard: openWizard,
      openEditor: openEditor,
      openCamera: openCamera,
      openMedia: openMedia,
      openCollection: openCollection,

      createTempFile: widget.mediaHandeler.fsManager.createTempFile,
      createBackupFile: widget.mediaHandeler.fsManager.createBackupFile,

      reloadStore: widget.mediaHandeler.reloadStore,
      getMediaPath: widget.mediaHandeler.fsManager.getMediaPath,
      getMediaLabel: widget.mediaHandeler.fsManager.getMediaLabel,
      getPreviewPath: widget.mediaHandeler.fsManager.getPreviewPath,
      getNotesPath: widget.mediaHandeler.fsManager.getNotesPath,
      getText: widget.mediaHandeler.fsManager.getText,

      getMediaMultipleByIds: widget.mediaHandeler.getMediaMultipleByIds,
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

  Future<bool> openMoveWizard(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) async {
    return openWizard(ctx, mediaMultiple, UniversalMediaSource.move);
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
}
