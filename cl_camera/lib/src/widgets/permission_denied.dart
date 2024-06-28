import 'package:cl_camera/src/state/camera_theme.dart';
import 'package:flutter/material.dart';

class CameraPermissionDenied extends StatelessWidget {
  const CameraPermissionDenied({
    required this.message,
    super.key,
    this.onDone,
    this.onOpenSettings,
  });

  final String message;
  final VoidCallback? onDone;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: CameraTheme.of(context).themeData.displayTextStyle,
              ),
              if (onDone != null || onOpenSettings != null) ...[
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onDone != null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: onDone,
                          label: const Text('Go Back'),
                          icon: Icon(
                            CameraTheme.of(context).themeData.exitCamera,
                          ),
                        ),
                      ),
                    if (onDone != null && onOpenSettings != null)
                      const SizedBox(
                        width: 16,
                      ),
                    if (onOpenSettings != null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: onOpenSettings,
                          label: const Text('Open Settings'),
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
