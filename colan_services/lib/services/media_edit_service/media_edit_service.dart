import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_editors/media_editors.dart';
import 'package:store/store.dart';

class MediaEditService extends ConsumerWidget {
  const MediaEditService({
    required this.mediaId,
    required this.canDuplicateMedia,
    required this.onDone,
    super.key,
  });

  final int? mediaId;
  final bool canDuplicateMedia;
  final Future<void> Function({CLMedia? media}) onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMedia(
      id: mediaId!,
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
        // ignore: dead_code
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetMedia',
      ),
      builder: (media) {
        if (media == null) {
          return BasicPageService.message(message: ' Media not found');
        }

        return GetMediaUri(
          id: media.id!,
          errorBuilder: (_, __) {
            throw UnimplementedError('errorBuilder');
            // ignore: dead_code
          },
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetMediaUri',
          ),
          builder: (mediaUri) {
            return GetStoreUpdater(
              errorBuilder: (_, __) {
                throw UnimplementedError('errorBuilder');
                // ignore: dead_code
              },
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetStoreUpdater',
              ),
              builder: (theStore) {
                return InvokeEditor(
                  mediaUri: mediaUri!,
                  mediaType: media.type,
                  canDuplicateMedia: canDuplicateMedia,
                  onCreateNewFile: () async {
                    return theStore.createTempFile(ext: media.fExt);
                  },
                  onCancel: onDone,
                  onSave: (file, {required overwrite}) async {
                    final CLMedia resultMedia;
                    if (overwrite) {
                      final confirmed = await ConfirmAction.replaceMedia(
                            context,
                            ref,
                            media: media,
                          ) ??
                          false;
                      if (confirmed && context.mounted) {
                        resultMedia = await theStore.mediaUpdater
                            .replaceContent(file, media: media);
                      } else {
                        resultMedia = media;
                      }
                    } else {
                      final confirmed =
                          await ConfirmAction.cloneAndReplaceMedia(
                                context,
                                ref,
                                media: media,
                              ) ??
                              false;
                      if (confirmed && context.mounted) {
                        resultMedia = await theStore.mediaUpdater
                            .updateCloneAndReplaceContent(
                          file,
                          media: media,
                        );
                      } else {
                        resultMedia = media;
                      }
                    }

                    if (context.mounted) {
                      await onDone(media: resultMedia);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class InvokeEditor extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
          PageManager.of(context, ref).pop();
        });
        return Container();
      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PageManager.of(context, ref).pop();
        });
        return Container();
    }
  }
}
