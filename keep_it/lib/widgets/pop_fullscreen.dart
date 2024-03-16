import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PopFullScreen extends StatelessWidget {
  const PopFullScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onBackground.withAlpha(
              192,
            ), // Color for the circular container
      ),
      child: CLButtonIcon.small(
        Icons.close,
        color: Theme.of(context).colorScheme.background.withAlpha(192),
        onTap: context.canPop()
            ? () {
                if (context.canPop()) {
                  context.pop();
                }
              }
            : null,
      ),
    );
  }
}
