import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../providers/filters.dart';
import 'ddmmyyyy_filter_view.dart';
import 'enum_filter_view.dart';
import 'text_filter.dart';

class TextFilterBox extends ConsumerWidget {
  const TextFilterBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);

    final defaultTextSearchFilter = filters.defaultTextSearchFilter;

    return TextFilterView(
      filter: defaultTextSearchFilter,
    );
  }
}

class FiltersView extends ConsumerStatefulWidget {
  const FiltersView({
    super.key,
    this.filters,
  });
  final List<CLFilter<CLMedia>>? filters;

  @override
  ConsumerState<FiltersView> createState() => FiltersViewState();
}

class FiltersViewState extends ConsumerState<FiltersView> {
  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;
    final hasFilter = filters != null && filters.isNotEmpty;
    final textTheme = ShadTheme.of(context).textTheme;
    return ShadAccordion<String>(
      children: [
        if (hasFilter)
          for (final filter in filters)
            ShadAccordionItem<String>(
              title: Badge(
                isLabelVisible: filter.isActive,
                child: Text(filter.name, style: textTheme.lead),
              ),
              value: filter.name,
              child: switch (filter.filterType) {
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
            ),
      ],
    );
  }
}
