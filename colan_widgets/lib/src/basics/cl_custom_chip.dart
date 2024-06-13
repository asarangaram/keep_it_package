import 'package:flutter/material.dart';

class CLCustomChip extends StatelessWidget {
  const CLCustomChip({
    required this.avatar,
    required this.label,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? avatar;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AbsorbPointer(
        child: Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          backgroundColor:
              const Color.fromARGB(255, 197, 195, 195).withAlpha(128),
          avatar: avatar,
          label: Padding(
            padding: const EdgeInsets.only(right: 2, top: 2, bottom: 2),
            child: label,
          ),
        ),
      ),
    );
  }
}
