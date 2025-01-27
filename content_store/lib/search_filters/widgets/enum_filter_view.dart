import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/enum_filter.dart';
import '../providers/filters.dart';

class EnumFilterView extends ConsumerWidget {
  const EnumFilterView({required this.filter, super.key});
  final CLFilter<CLMedia> filter;

  List<CLMenuItem> getMenuItems(
    WidgetRef ref,
  ) {
    if (filter.filterType == FilterType.enumFilter) {
      final clMediaTypeFilter = filter as EnumFilter;
      return [
        for (final entry in clMediaTypeFilter.labels.entries)
          CLMenuItem(
            title: entry.value,
            icon: clMediaTypeFilter.selectedValues.contains(entry.key)
                ? clIcons.selected
                : clIcons.deselected,
            onTap: () async {
              //ref.read(clMediaTypeFilterProvider.notifier).toggle(entry.key);
              ref
                  .read(filtersProvider.notifier)
                  .updateFilter(filter, 'toggle', entry.key);
              return true;
            },
          ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.filterType != FilterType.enumFilter) {
      throw Exception('filter is not EnumFilter');
    }
    final menuItems = getMenuItems(ref);

    return ListTile(
      title: CLText.large(
        filter.name,
        textAlign: TextAlign.start,
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: menuItems.map(
          (e) {
            return Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CLCustomChip(
                  label: Text(e.title),
                  avatar: Icon(e.icon),
                  onTap: e.onTap,
                  onLongPress: null,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

class EnumFilterViewRow extends ConsumerWidget {
  const EnumFilterViewRow({required this.filter, super.key});
  final CLFilter<CLMedia> filter;

  List<CLMenuItem> getMenuItems(
    WidgetRef ref,
  ) {
    if (filter.filterType == FilterType.enumFilter) {
      final clMediaTypeFilter = filter as EnumFilter;
      return [
        for (final entry in clMediaTypeFilter.labels.entries)
          CLMenuItem(
            title: entry.value,
            icon: clMediaTypeFilter.selectedValues.contains(entry.key)
                ? clIcons.selected
                : clIcons.deselected,
            onTap: () async {
              //ref.read(clMediaTypeFilterProvider.notifier).toggle(entry.key);
              ref
                  .read(filtersProvider.notifier)
                  .updateFilter(filter, 'toggle', entry.key);
              return true;
            },
          ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter.filterType != FilterType.enumFilter) {
      throw Exception('filter is not EnumFilter');
    }
    final menuItems = getMenuItems(ref);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...menuItems.map(
              (e) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: CLCustomChip(
                    label: Text(e.title),
                    avatar: Icon(e.icon),
                    onTap: e.onTap,
                    onLongPress: null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
