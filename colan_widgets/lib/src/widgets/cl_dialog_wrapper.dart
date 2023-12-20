import 'package:flutter/material.dart';

class CLDialogWrapper extends StatelessWidget {
  const CLDialogWrapper({
    super.key,
    this.isDialog = true,
    required this.child,
    this.backgroundColor,
    this.padding,
  });
  final bool isDialog;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    if (!isDialog) {
      return Padding(
          padding: padding ?? const EdgeInsets.all(8.0), child: child);
    }
    return Dialog(
      backgroundColor: backgroundColor,
      insetPadding: padding ?? const EdgeInsets.all(8.0),
      child: child,
    );
  }
}
