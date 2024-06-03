import 'package:app_loader/app_loader.dart';
import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
          required CameraDescription backCamera,
          required CameraDescription frontCamera,
          required void Function(String, {required bool isVideo}) onCapture,
          required Widget previewWidget,
        }) {
          return CLCamera(
            onCancel: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            cameras: [backCamera, frontCamera],
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
