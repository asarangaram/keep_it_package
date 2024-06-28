import 'package:cl_camera/src/state/camera_theme.dart';
import 'package:flutter/material.dart';

class CameraPermissionWait extends StatelessWidget {
  const CameraPermissionWait({
    required this.message,
    this.onDone,
    super.key,
  });

  final String message;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                message,
                style: CameraTheme.of(context).themeData.displayTextStyle,
              ),
              if (onDone != null) ...[
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton.icon(
                  onPressed: onDone,
                  label: const Text('Go back'),
                  icon: Icon(CameraTheme.of(context).themeData.exitCamera),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
