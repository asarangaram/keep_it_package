import 'package:cl_camera/cl_camera.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/captured_media.dart';
import 'widgets/get_cameras.dart';
import 'widgets/preview.dart';

class CLCameraService extends ConsumerWidget {
  const CLCameraService({
    required this.onDone,
    required this.onNewMedia,
    required this.getPreview,
    this.onCancel,
    super.key,
    this.onError,
  });

  final VoidCallback? onCancel;
  final Future<void> Function(List<CLMedia> mediaList) onDone;
  final Future<CLMedia?> Function(String, {required bool isVideo}) onNewMedia;
  final Widget Function(CLMedia media) getPreview;
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
            final media = await onNewMedia(file, isVideo: isVideo);
            if (media != null) {
              ref.read(capturedMediaProvider.notifier).add(media);
            }
          },
          previewWidget: PreviewCapturedMedia(
            sendMedia: onDone,
            getPreview: getPreview,
          ),
          themeData: DefaultCLCameraIcons(),
          onError: onError,
        );
      },
    );
  }
}
