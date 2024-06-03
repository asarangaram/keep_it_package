import 'package:app_loader/app_loader.dart';
import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_services/services/camera_service/widgets/get_cameras.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'simple_camera.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      child: GetCameras(
        builder: ({
          required CameraDescription backCamera,
          required CameraDescription frontCamera,
        }) {
          return CameraExampleHome(
            cameras: [backCamera, frontCamera],
            cameraIcons: CameraIcons(
              imageCamera: MdiIcons.camera,
              videoCamera: MdiIcons.video,
              pauseRecording: MdiIcons.pause,
              resumeRecording: MdiIcons.circle,
            ),
            textStyle: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: CLScaleType.small.fontSize),
            onCapture: (path, {required isVideo}) {},
            previewWidget: Container(
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
