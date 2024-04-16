import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    required this.previewWidget,
    required this.frontCamera,
    required this.backCamera,
    required this.onCapture,
    super.key,
  });

  final Widget previewWidget;
  final CameraDescription frontCamera;
  final CameraDescription backCamera;
  final void Function(String, {required bool isVideo}) onCapture;
  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      child: CLCamera(
        cameras: [
          backCamera,
          frontCamera,
        ],
        currentResolutionPreset: ResolutionPreset.high,
        onGeneratePreview: () {
          return previewWidget;
        },
        onCancel: () {},
        onInitializing: () {
          return const CLLoadingView(
            message: 'Initialzing',
          );
        },
        cameraIcons: CameraIcons(
          imageCamera: MdiIcons.camera,
          videoCamera: MdiIcons.video,
          pauseRecording: MdiIcons.pause,
          resumeRecording: MdiIcons.circle,
        ),
        onGetPermission: () async {
          return true;
        },
        onCapture: onCapture,
        textStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontSize: CLScaleType.small.fontSize),
      ),
    );
  }
}
