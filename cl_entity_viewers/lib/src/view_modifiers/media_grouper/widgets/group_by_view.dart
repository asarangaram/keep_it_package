import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

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
    final currValue = {
      for (final type in ['Media', 'Collection'])
        type: ref.watch(
          groupMethodProvider(type),
        ),
    };
    final textTheme = ShadTheme.of(context).textTheme;
    return ShadAccordion<String>.multiple(
      maintainState: true,
      initialValue: currValue.keys.toList(),
      children: [
        for (final type in currValue.entries)
          ShadAccordionItem<String>(
            value: type.key,
            title: Text('Group ${type.key} By', style: textTheme.lead),
            child: ShadRadioGroup<GroupTypes>(
              initialValue: currValue[type.key]!.method,
              onChanged: (v) {
                if (v != null) {
                  ref
                      .read(
                        groupMethodProvider(type.key).notifier,
                      )
                      .state = currValue[type.key]!.copyWith(method: v);
                }
              },
              axis: Axis.horizontal,
              items: GroupTypes.values.map(
                (e) => ShadRadio(
                  value: e,
                  label: Text(e.label),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
