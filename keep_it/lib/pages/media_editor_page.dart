import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/preview.dart';
import 'package:store/store.dart';

import '../widgets/store_manager.dart';

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

    return FullscreenLayout(
      hasBackground: false,
      backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
      child: StoreManager(
        builder: ({required storeAction}) {
          return GetMedia(
            id: mediaId!,
            buildOnData: (media) {
              if (media == null || !File(media.path).existsSync()) {
                return BasicPageService.message(
                  message: ' Media not found',
                );
              }

              return InvokeEditor(
                media: media,
                canDuplicateMedia: canDuplicateMedia,
                onCreateNewFile: () async {
                  return storeAction.createTempFile(ext: 'jpg');
                },
                onSave: (file, {required overwrite}) async {
                  if (overwrite) {
                    await ConfirmAction.replaceMedia(
                      context,
                      media: CLMedia(path: file, type: media.type),
                      getPreview: (CLMedia media) => Preview(media: media),
                      onConfirm: () async => storeAction
                          .replaceMedia([media], file, confirmed: true),
                    );
                  } else {
                    await ConfirmAction.cloneAndReplaceMedia(
                      context,
                      media: CLMedia(path: file, type: media.type),
                      getPreview: (CLMedia media) => Preview(media: media),
                      onConfirm: () async => storeAction
                          .cloneAndReplaceMedia([media], file, confirmed: true),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class InvokeEditor extends StatelessWidget {
  const InvokeEditor({
    required this.media,
    required this.onCreateNewFile,
    required this.onSave,
    required this.canDuplicateMedia,
    super.key,
  });
  final CLMedia media;
  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;
  final bool canDuplicateMedia;
  @override
  Widget build(BuildContext context) {
    switch (media.type) {
      case CLMediaType.image:
        return ImageEditService(
          file: File(media.path),
          onDone: () => CLPopScreen.onPop(context),
          onSave: onSave,
          onCreateNewFile: onCreateNewFile,
          canDuplicateMedia: canDuplicateMedia,
        );
      case CLMediaType.video:
        if (VideoEditServices.isSupported) {
          return VideoEditServices(
            File(media.path),
            onSave: onSave,
            onDone: () => CLPopScreen.onPop(context),
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
