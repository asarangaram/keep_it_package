import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/models/media_handler.dart';
import 'package:store/store.dart';

/// For the given media ID, this widget, calls the builder with the media file
/// and also provides a call back to get the modifiled file.
/// if overwrite is enabled, the original media is updated with updated file
/// or stored as another media, with same property as original

class MediaFileHandler extends ConsumerWidget {
  const MediaFileHandler({
    required this.builder,
    required this.errorBuilder,
    super.key,
    this.mediaId,
  });
  final int? mediaId;
  final Widget Function(
    String filePath, {
    required CLMediaType mediaType,
    required Future<void> Function(
      String updatedFilePath, {
      required bool overwrite,
    }) onSave,
  }) builder;
  final Widget Function(String errorMessage) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaId == null) {
      return errorBuilder('No Media Provided');
    }
    return GetDBManager(
      builder: (dbManager) {
        return GetMedia(
          id: mediaId!,
          buildOnData: (media) {
            if (media == null) {
              return errorBuilder('Media not found');
            }
            final mediaHandler =
                MediaHandler(media: media, dbManager: dbManager);
            return builder(
              media.path,
              mediaType: media.type,
              onSave: (outFile, {required overwrite}) => mediaHandler
                  .save(context, ref, outFile, overwrite: overwrite),
            );
          },
        );
      },
    );
  }
}
