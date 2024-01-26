import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../providers/state_providers.dart';

class PreviewSquareControlButton extends ConsumerWidget {
  const PreviewSquareControlButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPreviewSquare = ref.watch(isPreviewSquareProvider);
    return CLButtonIcon.small(
      isPreviewSquare ? MdiIcons.cropSquare : MdiIcons.arrowExpandAll,
      onTap: () {
        ref.read(isPreviewSquareProvider.notifier).state = !isPreviewSquare;
      },
    );
  }
}
