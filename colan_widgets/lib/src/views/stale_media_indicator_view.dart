import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CLStaleMediaIndicatorView extends StatelessWidget {
  const CLStaleMediaIndicatorView({
    required this.staleMediaCount,
    required this.onTap,
    super.key,
  });
  final int staleMediaCount;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CLText.tiny(
            'You have unclassified media. '
            '($staleMediaCount)',
          ),
          const SizedBox(
            width: 8,
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Show Now',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: CLScaleType.small.fontSize,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
