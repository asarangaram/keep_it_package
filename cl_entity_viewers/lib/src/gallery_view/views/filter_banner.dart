import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../common/models/viewer_entity_mixin.dart';

class FilterBanner extends StatelessWidget {
  const FilterBanner({
    super.key,
    required this.filterred,
    required this.incoming,
  });

  final List<ViewerEntity> filterred;
  final List<ViewerEntity> incoming;

  @override
  Widget build(BuildContext context) {
    if (incoming.isEmpty || filterred.length == incoming.length) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        color: ShadTheme.of(context).colorScheme.mutedForeground,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Center(
          child: Text(
            ' ${filterred.length} out of '
            '${incoming.length} matches',
            style: ShadTheme.of(context)
                .textTheme
                .small
                .copyWith(color: ShadTheme.of(context).colorScheme.muted),
          ),
        ),
      ),
    );
  }
}
