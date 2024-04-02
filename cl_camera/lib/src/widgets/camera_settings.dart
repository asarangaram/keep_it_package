import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CameraSettings extends StatelessWidget {
  const CameraSettings({
    required this.onClose,
    required this.controller,
    required this.children,
    super.key,
  });
  final VoidCallback onClose;
  final CameraController controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const foregroundColor = Colors.white;
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.down,
      onDismissed: (direction) {
        if (direction == DismissDirection.down) {
          onClose();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: foregroundColor)),
          /* borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ), */
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: CLButtonIcon.standard(
                Icons.close,
                onTap: onClose,
                color: foregroundColor,
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
