import 'package:app_loader/app_loader.dart';
import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      child: CameraService(
        collectionId: collectionId,
        onDone: () {
          if (context.canPop()) {
            context.pop();
          }
        },
        builder: ({
          required List<CameraDescription> cameras,
          required void Function(String, {required bool isVideo}) onCapture,
          required Widget previewWidget,
        }) {
          return CLCamera(
            onCancel: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            cameras: cameras,
            textStyle: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: CLScaleType.small.fontSize),
            onCapture: onCapture,
            previewWidget: previewWidget,
          );
        },
      ),
    );
  }
}
