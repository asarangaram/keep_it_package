import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_text.dart';

class MainHeader extends ConsumerWidget {
  const MainHeader({
    required this.backButton,
    super.key,
    this.actionsBuilders,
    this.title,
  });

  final List<
      Widget Function(
        BuildContext context,
      )>? actionsBuilders;

  final String? title;
  final Widget? backButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (backButton != null) backButton!,
                if (title != null)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CLText.veryLarge(
                        title!,
                      ),
                    ),
                  ),
                if (actionsBuilders != null && actionsBuilders!.isNotEmpty)
                  ...actionsBuilders!.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: e(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
