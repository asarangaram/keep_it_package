import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import 'widgets/camera_io_handler.dart';
import 'widgets/camera_view.dart';
import 'widgets/get_cameras.dart';

class CameraService extends StatelessWidget {
  const CameraService({
    required this.onDone,
    required this.onReceiveCapturedMedia,
    super.key,
    this.collectionId,
  });
  final int? collectionId;
  final VoidCallback onDone;
  final Future<bool> Function(
    BuildContext context,
    WidgetRef ref, {
    required List<CLMedia> entries,
    Collection? collection,
  }) onReceiveCapturedMedia;
  @override
  Widget build(BuildContext context) {
    return GetCollection(
      id: collectionId,
      buildOnData: (collection) {
        return GetCameras(
          builder: ({
            required CameraDescription frontCamera,
            required CameraDescription backCamera,
          }) {
            return CameraIOHandler(
              onDone: onDone,
              onReceiveCapturedMedia: onReceiveCapturedMedia,
              collection: collection,
              builder: ({
                required onCapture,
                required onError,
                required previewWidget,
              }) =>
                  CameraView(
                frontCamera: frontCamera,
                backCamera: backCamera,
                previewWidget: previewWidget,
                onCapture: onCapture,
                onError: onError,
              ),
            );
          },
        );
      },
    );
  }
}
