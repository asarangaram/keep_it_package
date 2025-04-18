import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/show_controls.dart';

class MediaBackground extends ConsumerWidget {
  const MediaBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

    return AnimatedOpacity(
      opacity: showControl.showBackground ? 0 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface),
      ),
    );
  }
}
