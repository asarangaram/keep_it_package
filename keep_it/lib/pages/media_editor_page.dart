import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_editors/media_editors.dart';
import 'package:store/store.dart';

class MediaEditorPage extends ConsumerWidget {
  const MediaEditorPage({
    required this.mediaId,
    required this.canDuplicateMedia,
    super.key,
  });
  final int? mediaId;
  final bool canDuplicateMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaId == null) {
      return BasicPageService.message(message: 'No Media Provided');
    }

    return GetStoreUpdater(
      builder: (theStore) {
        final media = theStore.getMediaById(mediaId);

        if (media == null) {
          return BasicPageService.message(message: ' Media not found');
        }

        return GetMediaUri(
          id: media.id!,
          builder: (mediaUri) {
            return InvokeEditor(
              mediaUri: mediaUri,
              mediaType: media.type,
              canDuplicateMedia: canDuplicateMedia,
              onCreateNewFile: () async {
                return theStore.createTempFile(ext: media.fExt);
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
                    resultMedia =
                        await theStore.replaceMedia(file, media: media);
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
                    resultMedia =
                        await theStore.cloneAndReplaceMedia(file, media: media);
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
      },
    );
  }
}

class InvokeEditor extends StatelessWidget {
  const InvokeEditor({
    required this.mediaUri,
    required this.mediaType,
    required this.onCreateNewFile,
    required this.onSave,
    required this.onCancel,
    required this.canDuplicateMedia,
    super.key,
  });
  final Uri mediaUri;
  final CLMediaType mediaType;
  final Future<String> Function() onCreateNewFile;
  final Future<void> Function(String, {required bool overwrite}) onSave;
  final Future<void> Function() onCancel;
  final bool canDuplicateMedia;
  @override
  Widget build(BuildContext context) {
    switch (mediaType) {
      case CLMediaType.image:
        return ImageEditor(
          uri: mediaUri,
          onCancel: onCancel,
          onSave: onSave,
          onCreateNewFile: onCreateNewFile,
          canDuplicateMedia: canDuplicateMedia,
        );
      case CLMediaType.video:
        if (VideoEditor.isSupported) {
          return VideoEditor(
            uri: mediaUri,
            onSave: onSave,
            onDone: onCancel,
            onCreateNewFile: onCreateNewFile,
            canDuplicateMedia: canDuplicateMedia,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CLPopScreen.onPop(context);
        });
        return Container();
      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CLPopScreen.onPop(context);
        });
        return Container();
    }
  }
}
