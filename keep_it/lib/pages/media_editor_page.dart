import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/modules/shared_media/cl_media_process.dart';
import 'package:store/store.dart';

import '../widgets/editors/image/image_editor.dart';
import '../widgets/editors/video/video_trimmer.dart';
import '../widgets/folders_and_files/media_as_file.dart';

class MediaEditorPage extends ConsumerWidget {
  const MediaEditorPage({
    required this.mediaId,
    super.key,
  });
  final int? mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mediaId == null) {
      return const CLErrorView(errorMessage: 'No Media Provided');
    }
    return GetDBManager(
      builder: (dbManager) {
        return GetMedia(
          id: mediaId!,
          buildOnData: (media) {
            if (media.isValidMedia && media.type == CLMediaType.image) {
              return CLImageEditor(
                file: File(media.path),
                onSave: (outFile, {required overwrite}) async {
                  print(outFile);
                  final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmAction(
                            title: 'Confirm '
                                '${overwrite ? "Replace" : "Save New"} ',
                            message: 'Save this image? ',
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
                      type: CLMediaType.video,
                      collectionId: media.collectionId,
                      md5String: md5String,
                      originalDate: media.originalDate,
                      createdDate: media.createdDate,
                    );
                  }
                  await dbManager.upsertMedia(
                    collectionId: media.collectionId!,
                    media: updatedMedia,
                    onPrepareMedia: (m, {required targetDir}) async {
                      final updated = (await m.moveFile(targetDir: targetDir))
                          .getMetadata();

                      return updated;
                    },
                  );
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
                onDiscard: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              );
            }

            if (media.isValidMedia && media.type == CLMediaType.video) {
              return TrimmerView(
                File(media.path),
                onSave: (outFile, {required overwrite}) async {
                  final md5String = await File(outFile).checksum;
                  final CLMedia updatedMedia;
                  if (overwrite) {
                    updatedMedia =
                        media.copyWith(path: outFile, md5String: md5String);
                  } else {
                    updatedMedia = CLMedia(
                      path: outFile,
                      type: CLMediaType.video,
                      collectionId: media.collectionId,
                      md5String: md5String,
                      originalDate: media.originalDate,
                      createdDate: media.createdDate,
                    );
                  }
                  await dbManager.upsertMedia(
                    collectionId: media.collectionId!,
                    media: updatedMedia,
                    onPrepareMedia: (m, {required targetDir}) async {
                      final updated = (await m.moveFile(targetDir: targetDir))
                          .getMetadata();

                      return updated;
                    },
                  );
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    }
                  }
                },
                onDiscard: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              );
            }
            return const CLErrorView(errorMessage: 'Not supported yet');
          },
        );
      },
    );
  }
}
