import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_preview.dart';
import 'camera_preview_core.dart';

class CameraFullScreen extends ConsumerStatefulWidget {
  const CameraFullScreen({super.key});

  @override
  ConsumerState<CameraFullScreen> createState() => _CameraFullScreenState();
}

class _CameraFullScreenState extends ConsumerState<CameraFullScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CameraPreviewCore(),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
            ),
          ),
        ),
        const CameraPreviewWidget(),
      ],
    );
  }
}
