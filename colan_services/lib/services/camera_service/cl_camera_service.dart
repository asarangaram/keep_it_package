import 'dart:io';

import 'package:cl_camera/cl_camera.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../internal/fullscreen_layout.dart';
import 'providers/captured_media.dart';
import 'widgets/get_cameras.dart';
import 'widgets/preview.dart';

class CLCameraService extends ConsumerWidget {
  const CLCameraService({
    required this.collectionId,
    super.key,
  });

  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      useSafeArea: false,
      child: GetStoreUpdater(
        errorBuilder: (_, __) {
          throw UnimplementedError('errorBuilder');
          // ignore: dead_code
        },
        loadingBuilder: () => CLLoader.widget(
          debugMessage: 'GetStoreUpdater',
        ),
        builder: (theStore) {
          return GetCollection(
            id: collectionId,
            errorBuilder: (_, __) {
              throw UnimplementedError('errorBuilder');
              // ignore: dead_code
            },
            loadingBuilder: () => CLLoader.widget(
              debugMessage: 'GetCollection',
            ),
            builder: (collection) {
              return CLCameraService0(
                parentIdentifier: 'CLCameraService',
                onCancel: () => PageManager.of(context).pop(),
                onNewMedia: (path, {required isVideo}) async {
                  return theStore.mediaUpdater.create(
                    path,
                    type: isVideo ? CLMediaType.video : CLMediaType.image,
                    collectionId: () => collection?.id,
                  );
                },
                onDone: (mediaList) async {
                  await MediaWizardService.openWizard(
                    context,
                    ref,
                    CLSharedMedia(
                      entries: mediaList,
                      type: UniversalMediaSource.captured,
                      collection: collection,
                    ),
                  );

                  if (context.mounted) {
                    PageManager.of(context).pop();
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

class CLCameraService0 extends ConsumerWidget {
  const CLCameraService0({
    required this.parentIdentifier,
    required this.onDone,
    required this.onNewMedia,
    this.onCancel,
    super.key,
    this.onError,
  });
  final String parentIdentifier;
  final VoidCallback? onCancel;
  final Future<void> Function(List<CLMedia> mediaList) onDone;
  final Future<CLMedia?> Function(String, {required bool isVideo}) onNewMedia;

  final void Function(String message, {required dynamic error})? onError;
  static Future<bool> invokeWithSufficientPermission(
    BuildContext context,
    Future<void> Function() callback, {
    required CLCameraThemeData themeData,
  }) async =>
      CLCamera.invokeWithSufficientPermission(
        context,
        callback,
        themeData: themeData,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetCameras(
      builder: ({required cameras}) {
        return CLCamera(
          onCancel: () {
            // Confirm ?
            ref.read(capturedMediaProvider.notifier).clear();
            onCancel?.call();
          },
          cameras: cameras,
          onCapture: (file, {required isVideo}) async {
            String? updatedFile;
            if (isVideo) {
              /// Refer https://github.com/flutter/flutter/issues/148335
              /// android_camerax plugin returns .temp extension
              /// for recorded video
              final currentExtension = p.extension(file);
              if (currentExtension.toLowerCase() != '.mp4') {
                updatedFile = p.setExtension(file, '.mp4');
                File(file).copySync(updatedFile);
                File(file).deleteSync();
              }
            }
            final media =
                await onNewMedia(updatedFile ?? file, isVideo: isVideo);
            if (media != null) {
              ref.read(capturedMediaProvider.notifier).add(media);
            }
          },
          previewWidget: PreviewCapturedMedia(
            sendMedia: onDone,
            parentIdentifier: parentIdentifier,
          ),
          themeData: DefaultCLCameraIcons(),
          onError: onError,
        );
      },
    );
  }
}
