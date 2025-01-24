import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// CLButtonText with icon ! -- Can we reuse?
class LabelViewer extends StatelessWidget {
  const LabelViewer({
    required this.label,
    this.icon,
    this.onTap,
    super.key,
  });

  final void Function()? onTap;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Center(child: CLText.large(label))),
          if (onTap != null && icon != null) ...[
            const SizedBox(
              width: 8,
            ),
            Transform.translate(
              offset: const Offset(0, -4),
              child: CLIcon.verySmall(
                icon!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
