import 'package:flutter/material.dart';

import '../models/camera_mode.dart';

class MenuCameraMode extends StatelessWidget {
  const MenuCameraMode({
    required this.onUpdateMode,
    required this.currMode,
    required this.textStyle,
    super.key,
  });

  final CameraMode currMode;
  final void Function(CameraMode type) onUpdateMode;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: [
            for (final type in CameraMode.values)
              TextButton(
                child: Text(
                  type.capitalizedName,
                  style: (textStyle ?? const TextStyle()).copyWith(
                    color: type == currMode
                        ? Colors.yellow.shade300
                        : Colors.yellow.shade100,
                  ),
                ),
                onPressed: () => onUpdateMode(type),
              ),
          ]
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: e,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
