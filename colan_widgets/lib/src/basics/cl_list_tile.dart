import 'package:flutter/material.dart';

import 'cl_text.dart';

class CLListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subTitle;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function()? onDoubleTap;

  final Color? tileColor;

  final bool isSelected;

  // Constructor for the custom list tile
  const CLListTile({
    super.key,
    this.leading,
    required this.title,
    this.subTitle,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.tileColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CLText.veryLarge(
                        title,
                        // textAlign: TextAlign.center,
                      ),
                      if (subTitle != null) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CLText.small(
                            subTitle!,
                            textAlign: TextAlign.start,
                          ),
                        )
                      ]
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
