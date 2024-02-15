import 'package:flutter/material.dart';

// If Scrolling is enabled,
//  Nothing but a grid view, but some tweaks
//  Avoid using it, instead use GridView
class Matrix2D extends StatelessWidget {
  const Matrix2D({
    required this.itemBuilder,
    required this.hCount,
    required int vCount,
    required this.itemCount,
    this.strictMartrix = true,
    super.key,
  }) : vCount_ = vCount;
  const Matrix2D.scrollable({
    required this.itemBuilder,
    required this.hCount,
    required this.itemCount,
    this.strictMartrix = true,
    super.key,
  }) : vCount_ = null;

  final Widget Function(BuildContext context, int index) itemBuilder;

  final int hCount;
  final int? vCount_;
  final int itemCount;
  final bool strictMartrix;

  @override
  Widget build(BuildContext context) {
    final numRows = vCount_ ?? (itemCount + hCount - 1) ~/ hCount;
    final lastCount = (strictMartrix
        ? hCount
        : (hCount * numRows > itemCount)
            ? itemCount - hCount * (numRows - 1)
            : hCount);
    if (vCount_ == null) {
      return ComputeSizeAndBuild(
        builder: (context, size) {
          return ListView.builder(
            itemCount: numRows,
            itemBuilder: (context, r) {
              return SizedBox(
                height: size.width / hCount,
                width: size.width / hCount,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var c = 0;
                        c < (r == (numRows - 1) ? lastCount : hCount);
                        c++)
                      SizedBox.square(
                        dimension: size.width / hCount,
                        child: ((r * hCount + c) >= itemCount)
                            ? strictMartrix
                                ? Container()
                                : throw Exception('Unexpected')
                            : itemBuilder(context, r * hCount + c),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
    return ComputeSizeAndBuild(
      builder: (context, size) {
        final width = size.width / hCount;
        final height = size.height / numRows;

        return Column(
          children: [
            for (var r = 0; r < numRows; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var c = 0;
                      c < (r == (numRows - 1) ? lastCount : hCount);
                      c++)
                    SizedBox(
                      width: width,
                      height: height,
                      child: ((r * hCount + c) >= itemCount)
                          ? strictMartrix
                              ? Container()
                              : throw Exception('Unexpected')
                          : itemBuilder(context, r * hCount + c),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

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
