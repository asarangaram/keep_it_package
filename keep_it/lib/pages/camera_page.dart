import 'package:app_loader/app_loader.dart';
import 'package:camera/camera.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/camera_service/widgets/get_cameras.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'simple_camera.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      child: (false)
          ? CameraService(
              collectionId: collectionId,
              onReceiveCapturedMedia: onReceiveCapturedMedia,
              onDone: () {
                if (context.mounted) {
                  if (context.canPop()) {
                    context.pop();
                  }
                }
              },
            )
          : GetCameras(
              builder: ({
                required CameraDescription backCamera,
                required CameraDescription frontCamera,
              }) {
                return CameraExampleHome(
                  cameras: [backCamera, frontCamera],
                );
              },
            ),
    );
  }
}
