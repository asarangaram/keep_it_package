import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../notifier/ui_state.dart';

class OnDarkMode extends StatelessWidget {
  const OnDarkMode({required this.iconColor, super.key});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final isDartTheme = uiStateManager.notifier.select(
      (state) => state.isDartTheme,
    );
    return ListenableBuilder(
      listenable: isDartTheme,
      builder: (_, __) {
        return ShadButton.ghost(
          onPressed: uiStateManager.notifier.toggleDarkTheme,
          child: Icon(
            isDartTheme.value ? LucideIcons.moon : LucideIcons.sunMoon,
            color: iconColor,
            size: 20,
          ),
        );
      },
    );
  }
}
