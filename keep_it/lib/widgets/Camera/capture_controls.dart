import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'providers/camera_state.dart';

class CaptureControls extends ConsumerStatefulWidget {
  const CaptureControls({
    super.key,
  });

  @override
  ConsumerState<CaptureControls> createState() => _CaptureControlsState();
}

class _CaptureControlsState extends ConsumerState<CaptureControls> {
  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraStateProvider);
    final controller = cameraState.controller;
    final isVideo = cameraState.isVideo;
    final busy = cameraState.isTakingPicture || cameraState.isRecordingVideo;
    return LayoutBuilder(
      builder: (context, constrains) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!busy)
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
                        color: !isVideo ? Colors.yellow.shade300 : Colors.grey,
                        onTap: () {
                          ref
                              .read(
                                cameraStateProvider.notifier,
                              )
                              .setPhotoMode();
                        },
                      ),
                      CLButtonText.standard(
                        'Video',
                        color: isVideo ? Colors.yellow.shade300 : Colors.grey,
                        onTap: () {
                          ref
                              .read(
                                cameraStateProvider.notifier,
                              )
                              .setVideoMode();
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
                  onPressed: ref
                      .read(cameraStateProvider.notifier)
                      .primaryButtonAction,
                  icon: cameraState.isVideo
                      ? cameraState.isRecordingVideo
                          ? cameraState.isRecordingPaused
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
                if (cameraState.canPause)
                  Flexible(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CircularButton(
                          onPressed: ref
                              .read(cameraStateProvider.notifier)
                              .secondaryButtonAction,
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
