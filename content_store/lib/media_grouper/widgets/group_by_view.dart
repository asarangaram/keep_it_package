import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/media_grouper.dart';
import '../providers/media_grouper.dart';

class GroupByView extends ConsumerWidget {
  const GroupByView({
    required this.parentIdentifier,
    required this.groupBy,
    super.key,
  });
  final String parentIdentifier;
  final GroupBy groupBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currValue = {
      for (final type in ['Media', 'Collection'])
        type: ref.watch(
          groupMethodProvider('$parentIdentifier/$type'),
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
                        groupMethodProvider('$parentIdentifier/${type.key}')
                            .notifier,
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
