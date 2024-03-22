import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CaptureControls extends StatefulWidget {
  const CaptureControls({
    required this.controller,
    required this.isVideoCamera,
    required this.isInUse,
    required this.isTakingPicture,
    required this.isRecordingVideo,
    required this.onChanageCameraMode,
    required this.isRecordingVideoPaused,
    required this.onPauseVideoRecording,
    required this.onStartVideoRecording,
    required this.onStopVideoRecording,
    required this.onResumeVideoRecording,
    required this.onTakePicture,
    super.key,
  });
  final CameraController controller;
  final bool isVideoCamera;
  final bool isInUse;
  final bool isTakingPicture;
  final bool isRecordingVideo;
  final bool isRecordingVideoPaused;
  final void Function({required bool isVideoCamera}) onChanageCameraMode;
  final VoidCallback onStartVideoRecording;
  final VoidCallback onStopVideoRecording;
  final VoidCallback onPauseVideoRecording;
  final VoidCallback onResumeVideoRecording;
  final VoidCallback onTakePicture;

  @override
  State<CaptureControls> createState() => _CaptureControlsState();
}

class _CaptureControlsState extends State<CaptureControls> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    /* final busy =
        controller.value.isTakingPicture || controller.value.isRecordingVideo; */
    return LayoutBuilder(
      builder: (context, constrains) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!widget.isInUse)
              SizedBox(
                width: constrains.maxWidth,
                height: kMinInteractiveDimension,
                child: Center(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      CLButtonText.standard(
                        'Photo',
                        color: !widget.isVideoCamera
                            ? Colors.yellow.shade300
                            : Colors.grey,
                        onTap: () {
                          widget.onChanageCameraMode(isVideoCamera: false);
                        },
                      ),
                      CLButtonText.standard(
                        'Video',
                        color: widget.isVideoCamera
                            ? Colors.yellow.shade300
                            : Colors.grey,
                        onTap: () {
                          widget.onChanageCameraMode(isVideoCamera: true);
                        },
                      ),
                    ]
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(),
                ),
                CircularButton(
                  onPressed: widget.isRecordingVideo
                      ? null
                      : widget.isVideoCamera
                          ? widget.isRecordingVideo
                              ? widget.isRecordingVideoPaused
                                  ? widget.onResumeVideoRecording
                                  : widget.onPauseVideoRecording
                              : widget.onStartVideoRecording
                          : widget.onTakePicture,
                  icon: widget.isVideoCamera
                      ? widget.isRecordingVideo
                          ? widget.isRecordingVideoPaused
                              ? MdiIcons.circle
                              : MdiIcons.pause
                          : MdiIcons.video
                      : MdiIcons.camera,
                  size: 44,
                  backgroundColor: controller.value.isRecordingVideo
                      ? Theme.of(context).colorScheme.error
                      : null,
                  foregroundColor: controller.value.isRecordingVideo
                      ? Theme.of(context).colorScheme.onError
                      : null,
                ),
                if (widget.isVideoCamera && widget.isRecordingVideo)
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CircularButton(
                          onPressed: widget.onStopVideoRecording,
                          icon: MdiIcons.stop,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(child: Container()),
              ],
            ),
          ],
        );
      },
    );
  }
}
