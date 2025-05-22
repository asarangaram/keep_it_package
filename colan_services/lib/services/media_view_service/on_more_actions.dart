import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app_start_service/notifiers/app_preferences.dart';

class OnMoreActions extends ConsumerWidget {
  const OnMoreActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor =
        ref.watch(appPreferenceProvider.select((e) => e.iconColor));
    return ShadButton.ghost(
      child: Icon(LucideIcons.circleEllipsis, color: iconColor, size: 20),
      onPressed: () {},
    );
  }
}
