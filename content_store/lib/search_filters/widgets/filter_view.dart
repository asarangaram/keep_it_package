import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../providers/filters.dart';
import 'ddmmyyyy_filter_view.dart';
import 'enum_filter_view.dart';
import 'text_filter.dart';

class FilterView extends ConsumerWidget {
  const FilterView({
    required this.filter,
    super.key,
  });
  final CLFilter<CLMedia> filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Indicator
          CLButtonIcon.tiny(
            Icons.delete_outline,
            color: Colors.red,
            onTap: () {
              ref.read(filtersProvider.notifier).removeFilter(filter);
            },
          ),
          const SizedBox(width: 12),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filter.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              switch (filter.filterType) {
                FilterType.stringFilter => TextFilterView(
                    filter: filter,
                  ),
                FilterType.booleanFilter => throw UnimplementedError(),
                FilterType.dateFilter => throw UnimplementedError(),
                FilterType.ddmmyyyyFilter =>
                  DDMMYYYYFilterViewRow(filter: filter),
                FilterType.enumFilter => EnumFilterViewRow(
                    filter: filter,
                  ),
              },
            ],
          ),
        ],
      ),
    );
  }
}
