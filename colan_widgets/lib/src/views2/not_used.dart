/* import 'package:flutter/material.dart';

class CLMatrix2DNonScrollable extends StatelessWidget {
  const CLMatrix2DNonScrollable({
    required this.itemBuilder,
    required this.hCount,
    required this.vCount,
    required this.layers,
    this.leadingRow,
    this.trailingRow,
    super.key,
  });

  final Widget Function(BuildContext context, int r, int c, int l) itemBuilder;
  final Widget? leadingRow;
  final Widget? trailingRow;

  final int hCount;
  final int vCount;
  final int layers;

  @override
  Widget build(BuildContext context) {
    return ComputeSizeAndBuild(
      builder: (context, size) {
        return SizedBox.fromSize(
          size: size,
          child: Column(
            children: [
              if (leadingRow != null) Flexible(child: leadingRow!),
              for (var r = 0; r < vCount; r++)
                for (var l = 0; l < layers; l++)
                  FlexibileOptional(
                    isFlexible: l == 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var c = 0; c < hCount; c++)
                          SizedBox(
                            width: size.width / hCount,
                            child: itemBuilder(context, r, c, l),
                          ),
                      ],
                    ),
                  ),
              if (trailingRow != null)
                Flexible(
                  child: trailingRow!,
                ),
            ],
          ),
        );
      },
    );
  }
}
 
class ItemDecoration extends StatelessWidget {
  const ItemDecoration({
    required this.child,
    required this.isLastLayer,
    required this.isFirstLayer,
    this.borderSide = BorderSide.none,
    super.key,
    this.decoration,
  });
  final Widget child;
  final bool isLastLayer;
  final bool isFirstLayer;
  final BorderSide borderSide;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    if (borderSide == BorderSide.none && decoration == null) return child;
    return Padding(
      padding: EdgeInsets.only(
        left: 2,
        right: 2,
        top: isFirstLayer ? 2 : 0,
        bottom: isLastLayer ? 2 : 0,
      ),
      child: DecoratedBox(
        decoration: (decoration ?? const BoxDecoration()).copyWith(
          border: Border(
            left: borderSide,
            right: borderSide,
            top: isFirstLayer ? borderSide : BorderSide.none,
            bottom: isLastLayer ? borderSide : BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }
}
class VidoePlayIcon extends StatelessWidget {
  const VidoePlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(192), // Color for the circular container
      ),
      child: CLIcon.veryLarge(
        Icons.play_arrow_sharp,
        color: Theme.of(context).colorScheme.background.withAlpha(192),
      ),
    );
  }
}
 */
