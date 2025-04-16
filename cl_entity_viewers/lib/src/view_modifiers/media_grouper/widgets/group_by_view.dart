import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../gallery_grid_view/models/tab_identifier.dart';
import '../models/media_grouper.dart';
import '../providers/media_grouper.dart';

class GroupByView extends ConsumerWidget {
  const GroupByView({
    required this.tabIdentifier,
    required this.groupBy,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final GroupBy groupBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currValue = ref.watch(
      groupMethodProvider(tabIdentifier.tabId),
    );

    return ShadRadioGroup<GroupTypes>(
      initialValue: currValue.method,
      onChanged: (v) {
        if (v != null) {
          ref
              .read(
                groupMethodProvider(tabIdentifier.tabId).notifier,
              )
              .state = currValue.copyWith(method: v);
        }
      },
      axis: Axis.horizontal,
      items: GroupTypes.values.map(
        (e) => ShadRadio(
          value: e,
          label: Text(e.label),
        ),
      ),
    );
  }
}
