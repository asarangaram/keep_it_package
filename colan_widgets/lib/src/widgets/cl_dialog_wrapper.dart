import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLDialogWrapper extends StatelessWidget {
  const CLDialogWrapper({
    super.key,
    required this.child,
    this.isDialog = true,
    this.backgroundColor,
    this.padding,
    this.onCancel,
  });
  final bool isDialog;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Function()? onCancel;
  @override
  Widget build(BuildContext context) {
    if (!isDialog) {
      return child;
    }
    return AlertDialog(
      scrollable: true,

      //shape: const ContinuousRectangleBorder(),
      backgroundColor: backgroundColor,
      insetPadding: padding ?? const EdgeInsets.all(8.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: CLButtonIcon.small(
                Icons.close,
                onTap: onCancel,
              ),
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
