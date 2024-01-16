import 'package:flutter/material.dart';

class ComputeSizeAndBuild extends StatefulWidget {
  const ComputeSizeAndBuild({
    required this.builder,
    this.builderWhenNoSize,
    super.key,
  });

  final Widget Function(BuildContext context, Size size) builder;
  final Widget Function(BuildContext context)? builderWhenNoSize;

  @override
  State<StatefulWidget> createState() => ComputeSizeAndBuildState();
}

class ComputeSizeAndBuildState extends State<ComputeSizeAndBuild> {
  final GlobalKey _containerKey = GlobalKey();
  Size? computedSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _containerKey.currentContext!.findRenderObject()! as RenderBox;
      final widgetSize = renderBox.size;
      if (computedSize != widgetSize) {
        setState(() {
          computedSize = widgetSize;
        });
      }
    });

    return Container(
      key: _containerKey,
      child: (computedSize == null)
          ? widget.builderWhenNoSize?.call(context)
          : widget.builder(context, computedSize!),
    );
  }
}
