import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/camera_service/widgets/get_cameras.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'providers/captured_media.dart';
import 'widgets/preview.dart';

class CameraService extends ConsumerWidget {
  const CameraService({
    required this.collectionId,
    required this.builder,
    super.key,
  });
  final int? collectionId;
  final Widget Function({
    required CameraDescription backCamera,
    required CameraDescription frontCamera,
    required void Function(String, {required bool isVideo}) onCapture,
    required Widget previewWidget,
  }) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(anandas): Read from Settings
    const tempCollectionName = '*** Recently Captured';
    return GetDBManager(
      builder: (dbManager) {
        return GetCollection(
          id: collectionId,
          buildOnData: (collection) {
            return GetCameras(
              builder: ({required backCamera, required frontCamera}) {
                return builder(
                  backCamera: backCamera,
                  frontCamera: frontCamera,
                  onCapture: (path, {required isVideo}) async {
                    final md5String = await File(path).checksum;
                    CLMedia? media = CLMedia(
                      path: path,
                      type: isVideo ? CLMediaType.video : CLMediaType.image,
                      collectionId: collection?.id,
                      md5String: md5String,
                    );

                    if (collection == null) {
                      final Collection tempCollection;
                      tempCollection = await dbManager
                              .getCollectionByLabel(tempCollectionName) ??
                          await dbManager.upsertCollection(
                            collection:
                                const Collection(label: tempCollectionName),
                          );
                      media = await dbManager.upsertMedia(
                        collectionId: tempCollection.id!,
                        media: media.copyWith(isHidden: true),
                        onPrepareMedia: (m, {required targetDir}) async {
                          final updated =
                              (await m.moveFile(targetDir: targetDir))
                                  .getMetadata();
                          return updated;
                        },
                      );
                    } else {
                      media = await dbManager.upsertMedia(
                        collectionId: collection.id!,
                        media: media,
                        onPrepareMedia: (m, {required targetDir}) async {
                          final updated =
                              (await m.moveFile(targetDir: targetDir))
                                  .getMetadata();
                          return updated;
                        },
                      );
                    }

                    if (media != null) {
                      ref.read(capturedMediaProvider.notifier).add(media);
                    }
                  },
                  previewWidget: PreviewCapturedMedia(
                    sendMedia: (mediaList) async {
                      if (collection == null) {
                        unawaited(
                          onReceiveCapturedMedia(
                            context,
                            ref,
                            entries: mediaList,
                            collection: collection,
                          ),
                        );
                      }
                      ref.read(capturedMediaProvider.notifier).clear();
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
