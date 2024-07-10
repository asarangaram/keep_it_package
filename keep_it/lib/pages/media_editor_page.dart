import 'dart:io';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class MediaEditorPage extends StatelessWidget {
  const MediaEditorPage({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context) {
    if (mediaId == null) {
      return BasicPageService.message(message: 'No Media Provided');
    }

    return FullscreenLayout(
      hasBackground: false,
      backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
      child: MediaHandlerWidget(
        builder: ({required action}) {
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
                onCreateNewFile: () async {
                  return action.createTempFile(ext: 'jpg');
                },
                onSave: (file, {required overwrite}) async {
                  if (overwrite) {
                    await action.replaceMedia([media], file);
                  } else {
                    await action.cloneAndReplaceMedia([media], file);
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
    super.key,
  });
  final CLMedia media;
  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;

  @override
  Widget build(BuildContext context) {
    switch (media.type) {
      case CLMediaType.image:
        return ImageEditService(
          file: File(media.path),
          onDone: () => CLPopScreen.onPop(context),
          onSave: onSave,
          onCreateNewFile: onCreateNewFile,
        );
      case CLMediaType.video:
        return VideoEditServices(
          File(media.path),
          onSave: onSave,
          onDone: () => CLPopScreen.onPop(context),
        );
      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        return const CLErrorView(errorMessage: 'Not supported yet');
    }
  }
}
