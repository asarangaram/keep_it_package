import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:store/store.dart';

import '../camera/captured_media.dart';
import '../camera/providers/captured_media.dart';

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
          data: (cameras) => FutureBuilder(
            future: getApplicationCacheDirectory(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapShot.hasData && snapShot.data != null) {
                return FullscreenLayout(
                  useSafeArea: false,
                  child: CameraView(
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
                    onCancel: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
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
                      await Permission.camera.request();
                      final status = await Permission.camera.status;
                      return status.isGranted;
                    },
                    onCapture: (path, {required isVideo}) {
                      ref.read(capturedMediaProvider.notifier).add(
                            CLMedia(
                              path: path,
                              type: isVideo
                                  ? CLMediaType.video
                                  : CLMediaType.image,
                            ),
                          );
                    },
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: CLScaleType.small.fontSize),
                  ),
                );
              }
              return CLErrorView(errorMessage: snapShot.error.toString());
            },
          ),
          error: (e, st) => CLErrorView(errorMessage: e.toString()),
          loading: CLLoadingView.new,
        );
      },
    );
  }
}

final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return availableCameras();
});
