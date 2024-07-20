import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MediaEditorPage extends StatelessWidget {
  const MediaEditorPage({
    required this.mediaId,
    required this.canDuplicateMedia,
    super.key,
  });
  final int? mediaId;
  final bool canDuplicateMedia;

  @override
  Widget build(BuildContext context) {
    if (mediaId == null) {
      return BasicPageService.message(message: 'No Media Provided');
    }

    return GetMedia(
      id: mediaId!,
      buildOnData: (media) {
        if (media == null ||
            !File(TheStore.of(context).getMediaPath(media)).existsSync()) {
          return BasicPageService.message(
            message: ' Media not found',
          );
        }

        return InvokeEditor(
          media: media,
          canDuplicateMedia: canDuplicateMedia,
          onCreateNewFile: () async {
            return TheStore.of(context).createTempFile(ext: 'jpg');
          },
          onCancel: () async => context.pop(),
          onSave: (file, {required overwrite}) async {
            final CLMedia resultMedia;
            if (overwrite) {
              final confirmed = await ConfirmAction.replaceMedia(
                    context,
                    media: media,
                  ) ??
                  false;
              if (confirmed && context.mounted) {
                resultMedia = await TheStore.of(context)
                    .replaceMedia(context, media, file);
              } else {
                resultMedia = media;
              }
            } else {
              final confirmed = await ConfirmAction.cloneAndReplaceMedia(
                    context,
                    media: media,
                  ) ??
                  false;
              if (confirmed && context.mounted) {
                resultMedia = await TheStore.of(context)
                    .cloneAndReplaceMedia(context, media, file);
              } else {
                resultMedia = media;
              }
            }

            if (context.mounted) {
              context.pop(resultMedia);
            }
          },
        );
      },
    );
  }
}

class InvokeEditor extends StatelessWidget {
  const InvokeEditor({
    required this.media,
    required this.onCreateNewFile,
    required this.onSave,
    required this.onCancel,
    required this.canDuplicateMedia,
    super.key,
  });
  final CLMedia media;
  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;
  final Future<void> Function() onCancel;
  final bool canDuplicateMedia;
  @override
  Widget build(BuildContext context) {
    switch (media.type) {
      case CLMediaType.image:
        return ImageEditService(
          file: File(TheStore.of(context).getMediaPath(media)),
          onCancel: onCancel,
          onSave: onSave,
          onCreateNewFile: onCreateNewFile,
          canDuplicateMedia: canDuplicateMedia,
        );
      case CLMediaType.video:
        if (VideoEditServices.isSupported) {
          return VideoEditServices(
            File(TheStore.of(context).getMediaPath(media)),
            onSave: onSave,
            onDone: onCancel,
            canDuplicateMedia: canDuplicateMedia,
          );
        }
        return const CLErrorView(errorMessage: 'Not supported yet');
      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        return const CLErrorView(errorMessage: 'Not supported yet');
    }
  }
}
