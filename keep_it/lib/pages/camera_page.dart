import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../camera/captured_media.dart';
import '../camera/providers/camera_provider.dart';
import '../camera/providers/captured_media.dart';
import '../camera/views/close_camera.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camerasProvider);
    // TODO(anandas): Read these values from settings
    const defaultFrontCameraIndex = 0;
    const defaultBackCameraIndex = 0;

    return GetCollection(
      id: collectionId,
      buildOnData: (collection) {
        return camerasAsync.when(
          data: (cameras) {
            return FullscreenLayout(
              useSafeArea: false,
              child: CloseCameraOnSwipe(
                child: CLCamera(
                  cameras: [
                    cameras
                        .where(
                          (e) => e.lensDirection == CameraLensDirection.back,
                        )
                        .toList()[defaultBackCameraIndex],
                    cameras
                        .where(
                          (e) => e.lensDirection == CameraLensDirection.front,
                        )
                        .toList()[defaultFrontCameraIndex],
                  ],
                  currentResolutionPreset: ResolutionPreset.high,
                  onGeneratePreview: () {
                    return CapturedMedia(
                      collection: collection,
                    );
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
                    // Todo: Fix
                    /* await Permission.camera.request();
                    final status = await Permission.camera.status;
                    return status.isGranted; */
                    return true;
                  },
                  onCapture: (path, {required isVideo}) {
                    ref.read(capturedMediaProvider.notifier).add(
                          CLMedia(
                            path: path,
                            type:
                                isVideo ? CLMediaType.video : CLMediaType.image,
                          ),
                        );
                  },
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: CLScaleType.small.fontSize),
                ),
              ),
            );
          },
          error: (e, st) => CLErrorView(errorMessage: e.toString()),
          loading: CLLoadingView.new,
        );
      },
    );
  }
}
