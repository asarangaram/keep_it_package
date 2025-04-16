import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/tab_identifier.dart';
import '../builders/media_grouper.dart';
import '../providers/media_grouper.dart';

class GroupByView extends ConsumerWidget {
  const GroupByView({
    required this.viewIdentifier,
    required this.groupBy,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final GroupBy groupBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currValue = ref.watch(
      groupMethodProvider(viewIdentifier.parentID),
    );

    return ShadRadioGroup<GroupTypes>(
      initialValue: currValue.method,
      onChanged: (v) {
        if (v != null) {
          ref
              .read(
                groupMethodProvider(viewIdentifier.parentID).notifier,
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
