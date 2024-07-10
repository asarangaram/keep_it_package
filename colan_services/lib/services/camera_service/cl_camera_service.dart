import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'providers/captured_media.dart';
import 'widgets/core_service.dart';
import 'widgets/preview.dart';

class CLCameraService extends ConsumerWidget {
  const CLCameraService({
    required this.collectionId,
    required this.onReceiveCapturedMedia,
    this.onDone,
    super.key,
    this.onError,
  });
  final int? collectionId;

  final VoidCallback? onDone;
  final Future<void> Function() onReceiveCapturedMedia;
  static const tempCollectionName = '*** Recently Captured';
  final void Function(String message, {required dynamic error})? onError;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return GetCollection(
          id: collectionId,
          buildOnData: (collection) {
            return CameraServiceCore(
              onDone: () {
                // Confirm ?
                ref.read(capturedMediaProvider.notifier).clear();
                onDone?.call();
              },
              onError: onError,
              onCapture: (path, {required isVideo}) => onCapture(
                ref,
                path,
                isVideo: isVideo,
                dbManager: dbManager,
                collection: collection,
              ),
              onReceiveCapturedMedia: onReceiveCapturedMedia,
              previewWidget: PreviewCapturedMedia(
                sendMedia: (mediaList) async {
                  if (collection == null) {
                    final capturedMedia = ref.read(capturedMediaProvider);
                    await MediaWizardService.addMedia(
                      context,
                      ref,
                      media: CLSharedMedia(
                        entries: capturedMedia,
                        type: MediaSourceType.captured,
                      ),
                    );
                    await onReceiveCapturedMedia();
                  }
                  ref.read(capturedMediaProvider.notifier).clear();
                  onDone?.call();
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> onCapture(
    WidgetRef ref,
    String path, {
    required bool isVideo,
    required DBManager dbManager,
    Collection? collection,
  }) async {
    final md5String = await File(path).checksum;
    CLMedia? media = CLMedia(
      path: path,
      type: isVideo ? CLMediaType.video : CLMediaType.image,
      collectionId: collection?.id,
      md5String: md5String,
    );

    if (collection == null) {
      final Collection tempCollection;
      tempCollection =
          await dbManager.getCollectionByLabel(tempCollectionName) ??
              await dbManager.upsertCollection(
                collection: const Collection(label: tempCollectionName),
              );
      media = await dbManager.upsertMedia(
        collectionId: tempCollection.id!,
        media: media.copyWith(isHidden: true),
        onPrepareMedia: (m, {required targetDir}) async {
          final updated =
              (await m.moveFile(targetDir: targetDir)).getMetadata();
          return updated;
        },
      );
    } else {
      media = await dbManager.upsertMedia(
        collectionId: collection.id!,
        media: media,
        onPrepareMedia: (m, {required targetDir}) async {
          final updated =
              (await m.moveFile(targetDir: targetDir)).getMetadata();
          return updated;
        },
      );
    }
    if (media != null) {
      ref.read(capturedMediaProvider.notifier).add(media);
    }
  }
}
