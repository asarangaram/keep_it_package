import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'w2_get_db_manager.dart';
import 'w3_get_media.dart';

/// For the given media ID, this widget, calls the builder with the media file
/// and also provides a call back to get the modifiled file.
/// if overwrite is enabled, the original media is updated with updated file
/// or stored as another media, with same property as original

class MediaFileHandler extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (mediaId == null) {
      return errorBuilder('No Media Provided');
    }
    return GetMedia(
      id: mediaId!,
      buildOnData: (media) {
        return GetDBManager(
          builder: (dbManager) {
            return builder(
              media.path,
              mediaType: media.type,
              onSave: (outFile, {required overwrite}) async {
                final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return CLConfirmAction(
                          title: 'Confirm '
                              '${overwrite ? "Replace" : "Save New"} ',
                          message: '',
                          child: Image.file(File(outFile)),
                          onConfirm: ({required confirmed}) =>
                              Navigator.of(context).pop(confirmed),
                        );
                      },
                    ) ??
                    false;
                if (!confirmed) return;
                final md5String = await File(outFile).checksum;
                final CLMedia updatedMedia;
                if (overwrite) {
                  updatedMedia =
                      media.copyWith(path: outFile, md5String: md5String);
                } else {
                  updatedMedia = CLMedia(
                    path: outFile,
                    md5String: md5String,
                    type: media.type,
                    collectionId: media.collectionId,
                    originalDate: media.originalDate,
                    createdDate: media.createdDate,
                  );
                }
                await dbManager.upsertMedia(
                  collectionId: media.collectionId!,
                  media: updatedMedia,
                  onPrepareMedia: (m, {required targetDir}) async {
                    final updated = await m.moveFile(targetDir: targetDir);

                    return updated;
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
