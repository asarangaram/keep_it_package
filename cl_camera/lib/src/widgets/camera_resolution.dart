import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'camera_select.dart';

class CameraResolution extends StatelessWidget with CameraMixin {
  const CameraResolution({
    required this.onNextResolution,
    super.key,
    this.currResolution,
  });
  final VoidCallback onNextResolution;
  final Size? currResolution;

  @override
  Widget build(BuildContext context) {
    return CLButtonIconLabelled.small(
      Icons.photo_size_select_large,
      getResolutionString(
        currResolution,
      ),
      color: Colors.white,
      onTap: onNextResolution,
    );
  }
}
