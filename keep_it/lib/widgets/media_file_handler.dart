import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

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
                if (overwrite) {
                  final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return CLConfirmAction(
                            title: 'Confirm '
                                '${overwrite ? "Replace" : "Save New"} ',
                            message: '',
                            child: SizedBox.square(
                              dimension: 200,
                              child: Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                    child: PreviewService(
                                      media: CLMedia(
                                        path: outFile,
                                        type: media.type,
                                      ),
                                      keepAspectRatio: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onConfirm: ({required confirmed}) =>
                                Navigator.of(context).pop(confirmed),
                          );
                        },
                      ) ??
                      false;
                  if (!confirmed) return;
                }
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
