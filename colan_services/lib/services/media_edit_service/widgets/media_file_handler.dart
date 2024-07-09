import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../basic_page_service/basic_page_service.dart';
import '../../shared_media_service/models/media_handler.dart';

/// For the given media ID, this widget, calls the builder with the media file
/// and also provides a call back to get the modifiled file.
/// if overwrite is enabled, the original media is updated with updated file
/// or stored as another media, with same property as original

class MediaFileHandler extends ConsumerWidget {
  const MediaFileHandler({
    required this.builder,
    required this.mediaId,
    super.key,
  });
  final int mediaId;
  final Widget Function(
    String filePath, {
    required CLMediaType mediaType,
    required Future<void> Function(
      String updatedFilePath, {
      required bool overwrite,
    }) onSave,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return GetMedia(
          id: mediaId,
          buildOnData: (media) {
            if (media == null) {
              return BasicPageService.message(message: 'Media not found');
            }
            return builder(
              media.path,
              mediaType: media.type,
              onSave: (outFile, {required overwrite}) async {
                await MediaHandler(dbManager: dbManager, media: media)
                    .save(context, ref, outFile, overwrite: overwrite);
              },
            );
          },
        );
      },
    );
  }
}
