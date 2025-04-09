import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:media_editors/media_editors.dart';

import '../../internal/fullscreen_layout.dart';

class MediaEditService extends ConsumerWidget {
  const MediaEditService({
    required this.storeIdentity,
    required this.mediaId,
    required this.canDuplicateMedia,
    super.key,
  });

  final String storeIdentity;
  final int? mediaId;
  final bool canDuplicateMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      backgroundColor: CLTheme.of(context).colors.editorBackgroundColor,
      child: (mediaId == null)
          ? BasicPageService.nothingToShow(message: 'No Media Provided')
          : GetMedia(
              storeIdentity: storeIdentity,
              id: mediaId!,
              errorBuilder: (_, __) {
                throw UnimplementedError('errorBuilder');
              },
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetMedia',
              ),
              builder: (media) {
                if (media == null) {
                  return BasicPageService.message(message: ' Media not found');
                }

                return GetStore(
                  storeIdentity: storeIdentity,
                  errorBuilder: (_, __) {
                    throw UnimplementedError('errorBuilder');
                  },
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetStoreUpdater',
                  ),
                  builder: (theStore) {
                    return InvokeEditor(
                      mediaUri: media.mediaUri!,
                      mediaType: media.entity.mediaType,
                      canDuplicateMedia: canDuplicateMedia,
                      onCreateNewFile: () async {
                        return theStore.createTempFile(
                          ext: media.entity.extension!,
                        );
                      },
                      onCancel: () async {
                        PageManager.of(context).pop(media);
                      },
                      onSave: (file, {required overwrite}) async {
                        final mediaFile = await CLMediaFile.fromPath(file);
                        if (mediaFile != null) {
                          throw Exception('failed proces $file');
                        }
                        var resultMedia = media;

                        if (overwrite && context.mounted) {
                          final confirmed = await DialogService.replaceMedia(
                                context,
                                media: media.entity,
                              ) ??
                              false;
                          if (confirmed && context.mounted) {
                            if (mediaFile != null) {
                              resultMedia = await media.updateWith(
                                    mediaFile: mediaFile,
                                  ) ??
                                  media;
                            }
                          }
                        } else if (context.mounted) {
                          final confirmed =
                              await DialogService.cloneAndReplaceMedia(
                                    context,
                                    media: media.entity,
                                  ) ??
                                  false;
                          if (confirmed && context.mounted) {
                            resultMedia = await media.cloneWith(
                                  mediaFile: mediaFile!,
                                ) ??
                                media;
                          } else {
                            resultMedia = media;
                          }
                        }

                        if (context.mounted) {
                          PageManager.of(context).pop(resultMedia);
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
        if (ColanPlatformSupport.isMobilePlatform) {
          return VideoEditor(
            uri: mediaUri,
            onSave: onSave,
            onCancel: onCancel,
            onCreateNewFile: onCreateNewFile,
            canDuplicateMedia: canDuplicateMedia,
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PageManager.of(context).pop();
        });
        return Container();
      case CLMediaType.text:
      case CLMediaType.uri:
      case CLMediaType.audio:
      case CLMediaType.file:
      case CLMediaType.unknown:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PageManager.of(context).pop();
        });
        return Container();
    }
  }
}
