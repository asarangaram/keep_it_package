// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

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
    return GetStoreManager(
      builder: (storeManger) {
        return MediaHandlerWidget0(
          storeManager: storeManger,
          child: child,
        );
      },
    );
  }
}

class MediaHandlerWidget0 extends ConsumerStatefulWidget {
  const MediaHandlerWidget0({
    required this.child,
    required this.storeManager,
    super.key,
  });

  final Widget child;
  final StoreManager storeManager;

  @override
  ConsumerState<MediaHandlerWidget0> createState() =>
      _MediaHandlerWidgetState();
}

class _MediaHandlerWidgetState extends ConsumerState<MediaHandlerWidget0> {
  @override
  Widget build(BuildContext context) {
    final storeAction = StoreActions(
      /// Share modules
      shareMediaMultiple: shareMediaMultiple,
      shareFiles: ShareManager.onShareFiles,

      /// Open new screen
      openWizard: openWizard,
      openEditor: openEditor,
      openCamera: openCamera,
      openMedia: openMedia,
      openCollection: openCollection,
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
            (e) => widget.storeManager.getMediaAbsolutePath(e),
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
