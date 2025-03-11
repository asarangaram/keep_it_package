import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'app_bar.dart';

class BaseScaffold extends StatefulWidget {
  const BaseScaffold({
    super.key,
    required this.children,
    this.appBarTitle,
    this.editable,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapChildrenInScrollable = true,
    this.wrapSingleChildInColumn = true,
    this.alignment,
    this.gap = 8,
    this.appBarTitleWidget,
    this.appBarActions,
  });

  final List<Widget> children;
  final String? appBarTitle;
  final List<Widget>? editable;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapChildrenInScrollable;
  final bool wrapSingleChildInColumn;
  final Alignment? alignment;
  final double gap;
  final Widget? appBarTitleWidget;
  final List<Widget>? appBarActions;

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  late final MultiSplitViewController _controller;

  @override
  void initState() {
    _controller = MultiSplitViewController(areas: [
      for (final child in widget.children)
        Area(builder: (context, area) => child),
    ]);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    Widget left = Align(
      alignment: widget.alignment ?? Alignment.center,
      child: widget.children.length == 1 && !widget.wrapSingleChildInColumn
          ? widget.children[0]
          : Column(
              spacing: widget.gap,
              crossAxisAlignment: widget.crossAxisAlignment,
              children: widget.children,
            ),
    );

    if (widget.wrapChildrenInScrollable) {
      left = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: left,
      );
    }

    final Widget? right = widget.editable == null
        ? null
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Column(
                spacing: widget.gap,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.editable!,
              ),
            ),
          );

    return Scaffold(
      appBar: MyAppBar(
        title: widget.appBarTitle,
        titleWidget: widget.appBarTitleWidget,
        actions: widget.appBarActions,
      ),
      body: right != null
          ? MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                dividerPainter: _MyDividerPainter(
                  backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
                  highlightedBackgroundColor:
                      isDarkMode ? Colors.white24 : Colors.black26,
                ),
              ),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: MultiSplitView(
                  initialAreas: [
                    Area(
                      min: size.width / 2,
                      size: size.width * .7,
                    ),
                    Area(
                      min: size.width * .3,
                    ),
                  ],
                  controller: _controller,
                ),
              ),
            )
          : left,
    );
  }
}

class _MyDividerPainter extends DividerPainter {
  _MyDividerPainter({
    super.backgroundColor,
    super.highlightedBackgroundColor,
  });

  static const int backgroundKey = 0;

  /// Builds a tween map for animations.
  @override
  Map<int, Tween> buildTween() {
    final map = <int, Tween>{};
    if (animationEnabled &&
        backgroundColor != null &&
        highlightedBackgroundColor != null) {
      map[DividerPainter.backgroundKey] =
          ColorTween(begin: backgroundColor, end: highlightedBackgroundColor);
    }
    return map;
  }

  /// Paints the divider.
  @override
  void paint({
    required Axis dividerAxis,
    required bool resizable,
    required bool highlighted,
    required Canvas canvas,
    required Size dividerSize,
    required Map<int, dynamic> animatedValues,
  }) {
    var color = backgroundColor;
    var size = dividerSize;
    if (animationEnabled && animatedValues.containsKey(backgroundKey)) {
      color = animatedValues[backgroundKey] as Color?;
      size = Size(4, dividerSize.height);
    }

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color ?? Colors.transparent
      ..isAntiAlias = true;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }
}
