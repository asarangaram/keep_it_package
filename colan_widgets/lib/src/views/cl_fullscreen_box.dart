// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CLFullscreenBox extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;

  const CLFullscreenBox(
      {Key? key,
      required this.child,
      this.useSafeArea = false,
      this.backgroundColor,
      this.hasBorder = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: useSafeArea,
        left: useSafeArea,
        right: useSafeArea,
        bottom: useSafeArea,
        child: ClipRect(
          clipBehavior: Clip.antiAlias,
          child: ScaffoldBorder(
            hasBorder: hasBorder,
            child: LayoutBuilder(
              builder: ((context, constraints) => child),
            ),
          ),
        ),
      ),
    );
  }
}

class ScaffoldBorder extends StatelessWidget {
  const ScaffoldBorder({
    super.key,
    required this.hasBorder,
    required this.child,
  });
  final bool hasBorder;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!hasBorder) return child;
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: child,
    );
  }
}
