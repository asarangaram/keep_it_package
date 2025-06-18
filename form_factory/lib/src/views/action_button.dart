import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.menuItem,
    super.key,
    this.foregroundColor,
    this.backgroundColor,
    this.width,
    this.height,
    this.topLeft = Radius.zero,
    this.topRight = Radius.zero,
    this.bottomLeft = Radius.zero,
    this.bottomRight = Radius.zero,
  });

  const ActionButton.left({
    required this.menuItem,
    super.key,
    this.foregroundColor,
    this.backgroundColor,
    this.width,
    this.height,
    this.topLeft = const Radius.circular(16),
    this.bottomLeft = const Radius.circular(16),
  })  : topRight = Radius.zero,
        bottomRight = Radius.zero;
  const ActionButton.right({
    required this.menuItem,
    super.key,
    this.foregroundColor,
    this.backgroundColor,
    this.width,
    this.height,
    this.topRight = const Radius.circular(16),
    this.bottomRight = const Radius.circular(16),
  })  : topLeft = Radius.zero,
        bottomLeft = Radius.zero;

  final CLMenuItemBase menuItem;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final Radius topLeft;
  final Radius topRight;
  final Radius bottomLeft;
  final Radius bottomRight;

  @override
  Widget build(BuildContext context) {
    final menuButton = switch (menuItem) {
      _ => GestureDetector(
          onTap: (menuItem as CLMenuItem).onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CLIcon.standard(
                    color: backgroundColor,
                    menuItem.icon,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: FittedBox(
                        child: CLText.small(
                          menuItem.title,
                          color: foregroundColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        )
    };
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(),
          borderRadius: BorderRadius.only(
              topLeft: topLeft,
              bottomLeft: bottomLeft,
              topRight: topRight,
              bottomRight: bottomRight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AspectRatio(
            aspectRatio: 1,
            child: menuButton,
          ),
        ),
      ),
    );
  }
}
