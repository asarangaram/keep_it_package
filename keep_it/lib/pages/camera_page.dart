import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../camera/providers/captured_media.dart';
import '../camera/widgets/camera_view.dart';
import '../camera/widgets/captured_media.dart';
import '../camera/widgets/camera_io_handler.dart';
import '../camera/widgets/get_cameras.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;

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
              builder: (onCapture) => CameraView(
                frontCamera: frontCamera,
                backCamera: backCamera,
                previewWidget: CapturedMedia(
                  collection: collection,
                  onDone: () {
                    if (context.mounted) {
                      if (context.canPop()) {
                        context.pop();
                      }
                    }
                  },
                ),
                onCapture: onCapture,
              ),
            );
          },
        );
      },
    );
  }
}
