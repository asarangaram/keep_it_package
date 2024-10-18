import 'package:cl_camera/src/state/camera_theme.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionDenied extends StatelessWidget {
  const CameraPermissionDenied({
    required this.statuses,
    super.key,
    this.onDone,
    this.onOpenSettings,
  });

  final Map<Permission, PermissionStatus> statuses;
  final VoidCallback? onDone;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShowPermissionDeniedInfo(
            statuses: statuses,
          ),
          if (onDone != null || onOpenSettings != null) ...[
            const SizedBox(
              height: 32,
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
                      icon: Icon(
                        CameraTheme.of(context).themeData.cameraSettings,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ShowPermissionStatus extends StatelessWidget {
  const ShowPermissionStatus({
    required this.statuses,
    super.key,
  });

  final Map<Permission, PermissionStatus> statuses;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Permission.camera,
        Permission.microphone,
        Permission.location,
      ].map(
        (e) {
          final havePermission = statuses[e]?.isGranted ?? false;
          return Expanded(
            child: Center(
              child: LabeledIcon(
                iconData: CameraTheme.of(context).themeData.iconPermission(e),
                label: havePermission ? null : 'Denied',
                color: havePermission ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class LabeledIcon extends StatelessWidget {
  const LabeledIcon({
    required this.iconData,
    super.key,
    this.label,
    this.color,
  });
  final IconData iconData;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          color: color,
          size: CameraTheme.of(context).themeData.displayIconSize,
        ),
        Text(
          label ?? '  ',
          style: CameraTheme.of(context).themeData.displayTextStyle,
        ),
      ],
    );
  }
}

class ShowPermissionDeniedInfo extends StatelessWidget {
  const ShowPermissionDeniedInfo({
    required this.statuses,
    super.key,
  });

  final Map<Permission, PermissionStatus> statuses;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Some permissions are denied. Open Settings to fix the issues',
          style: CameraTheme.of(context).themeData.displayTextStyle.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 32,
        ),
        ShowPermissionStatus(statuses: statuses),
      ],
    );
  }
}
