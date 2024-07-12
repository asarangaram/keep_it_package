import 'package:flutter/material.dart';

class CLListTile extends StatelessWidget {
  // Constructor for the custom list tile
  const CLListTile({
    required this.title,
    super.key,
    this.leading,
    this.subTitle,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.tileColor,
    this.isSelected = false,
  });
  final Widget? leading;
  final Widget title;
  final Widget? subTitle;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;

  final Color? tileColor;

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.transparent,
        shadowColor: isSelected ? null : Colors.transparent,
        surfaceTintColor: isSelected ? null : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: () => onDoubleTap,
          onLongPress: () => onLongPress,
          child: Row(
            children: [
              if (leading != null) leading!,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      if (subTitle != null) ...[
                        const SizedBox(height: 10),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: subTitle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
