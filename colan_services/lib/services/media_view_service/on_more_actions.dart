import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnMoreActions extends ConsumerWidget {
  const OnMoreActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadButton.ghost(
      child: clIcons.extraMenu.iconFormatted(),
      onPressed: () {},
    );
  }
}
