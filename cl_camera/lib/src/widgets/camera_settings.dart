import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'cl_circular_button.dart';

enum CameraSettings { cameraSelection, exposureMode, focusMode }

class CameraSettingsHandler extends StatelessWidget {
  const CameraSettingsHandler({
    required this.currentSelection,
    required this.onSelection,
    super.key,
  });
  final CameraSettings? currentSelection;
  final void Function(CameraSettings cameraSettings) onSelection;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CameraSettings>(
      initialValue: currentSelection,
      onSelected: onSelection,
      itemBuilder: (context) {
        return CameraSettings.values
            .map(
              (e) => PopupMenuItem<CameraSettings>(
                value: e,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        MdiIcons.checkCircle,
                        color: (e == currentSelection)
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ),
                    Text(e.name),
                  ],
                ),
              ),
            )
            .toList();
      },
      child: CircularButton(
        icon: MdiIcons.dotsVertical,
        hasDecoration: false,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
