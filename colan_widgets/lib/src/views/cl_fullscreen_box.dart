// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CLFullscreenBox extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final Color backgroundColor;

  const CLFullscreenBox({
    Key? key,
    required this.child,
    this.useSafeArea = false,
    required this.backgroundColor,
  }) : super(key: key);

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
          child: LayoutBuilder(
            builder: ((context, constraints) => child),
          ),
        ),
      ),
    );
  }
}
