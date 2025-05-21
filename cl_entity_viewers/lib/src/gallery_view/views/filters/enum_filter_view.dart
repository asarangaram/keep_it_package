import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/viewer_entity_mixin.dart';
import '../../models/filter/base_filter.dart';
import '../../models/filter/enum_filter.dart';
import '../../providers/media_filters.dart';

class EnumFilterViewRow extends ConsumerWidget {
  const EnumFilterViewRow({
    required this.filter,
    required this.identifier,
    super.key,
  });
  final CLFilter<ViewerEntityMixin> filter;
  final String identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.filterType != FilterType.enumFilter) {
      throw Exception('filter is not EnumFilter');
    }

    final clMediaTypeFilter = filter as EnumFilter;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in clMediaTypeFilter.labels.entries)
              ShadCheckbox(
                value: clMediaTypeFilter.selectedValues.contains(entry.key),
                onChanged: (value) {
                  //ref.read(clMediaTypeFilterProvider.notifier).toggle(entry.key);
                  ref
                      .read(mediaFiltersProvider(identifier).notifier)
                      .updateFilter(filter, 'toggle', entry.key);
                },
                label: Text(entry.value),
              ),
          ],
        ),
      ),
    );
  }
}
