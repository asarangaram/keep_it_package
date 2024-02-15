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
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_computeSize);
    super.didChangeDependencies();
  }

  void _computeSize(_) {
    final renderBox =
        _containerKey.currentContext?.findRenderObject()! as RenderBox?;
    if (renderBox != null) {
      final widgetSize = renderBox.size;
      if (computedSize != widgetSize) {
        setState(() {
          computedSize = widgetSize;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      child: (computedSize == null)
          ? widget.builderWhenNoSize?.call(context)
          : widget.builder(context, computedSize!),
    );
  }
}
