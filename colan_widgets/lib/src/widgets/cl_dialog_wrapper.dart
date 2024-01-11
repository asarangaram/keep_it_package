import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLDialogWrapper extends StatelessWidget {
  const CLDialogWrapper({
    required this.child,
    super.key,
    this.isDialog = true,
    this.backgroundColor,
    this.padding,
    this.onCancel,
  });
  final bool isDialog;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final void Function()? onCancel;
  @override
  Widget build(BuildContext context) {
    if (!isDialog) {
      return child;
    }
    return Dialog(
      shape: const ContinuousRectangleBorder(),
      //scrollable: true,

      //shape: const ContinuousRectangleBorder(),
      backgroundColor: backgroundColor,
      insetPadding: padding ?? EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 32 + 20,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16, right: 16, bottom: 16),
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
