import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/tab_identifier.dart';
import '../builders/media_grouper.dart';
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
      groupMethodProvider(tabIdentifier.view.parentID),
    );

    return ShadRadioGroup<GroupTypes>(
      initialValue: currValue.method,
      onChanged: (v) {
        if (v != null) {
          ref
              .read(
                groupMethodProvider(tabIdentifier.view.parentID).notifier,
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
