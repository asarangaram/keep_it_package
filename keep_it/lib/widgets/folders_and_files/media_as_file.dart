import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_editors/media_editors.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class MediaAsFile extends ConsumerWidget {
  const MediaAsFile({
    required this.media,
    required this.parentIdentifier,
    required this.quickMenuScopeKey,
    required this.onTap,
    required this.actionControl,
    super.key,
  });
  final CLMedia media;
  final String parentIdentifier;
  final Future<bool?> Function()? onTap;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  final ActionControl actionControl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readOnly =
        (media.type == CLMediaType.video && !VideoEditor.isSupported) ||
            (!media.isMediaCached || !media.isMediaOriginal);

    return GetStoreUpdater(
      builder: (theStore) {
        return MediaMenu(
          onMove: () => MediaWizardService.openWizard(
            context,
            ref,
            CLSharedMedia(
              entries: [media],
              type: UniversalMediaSource.move,
            ),
          ),
          onDelete: () async {
            return theStore.mediaUpdater.delete(media.id!);
          },
          onShare: media.isMediaCached
              ? () => theStore.mediaUpdater.share(context, [media])
              : null,
          onEdit: readOnly
              ? null
              : () async {
                  /* final updatedMedia =  */ await Navigators.openEditor(
                    context,
                    ref,
                    media,
                    canDuplicateMedia: actionControl.canDuplicateMedia,
                  );
                  return true;
                },
          onDeleteLocalCopy: () async {
            return false;
          },
          onKeepOffline: () async {
            return false;
          },
          media: media,
          child: MediaViewService.preview(
            media,
            parentIdentifier: parentIdentifier,
          ),
        );
      },
    );
  }
}
