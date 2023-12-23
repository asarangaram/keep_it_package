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
    return Dialog(
      shape: const RoundedRectangleBorder(),
      //scrollable: true,

      //shape: const ContinuousRectangleBorder(),
      backgroundColor: backgroundColor,
      insetPadding: padding ?? const EdgeInsets.all(8.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 32 + 20,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16),
                  child: CLButtonIcon.small(
                    Icons.close,
                    onTap: onCancel,
                  ),
                ),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
