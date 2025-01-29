import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../providers/media_filters.dart';
import 'ddmmyyyy_filter_view.dart';
import 'enum_filter_view.dart';
import 'text_filter.dart';

class TextFilterBox extends ConsumerWidget {
  const TextFilterBox({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(mediaFiltersProvider(parentIdentifier));

    final defaultTextSearchFilter = filters.defaultTextSearchFilter;

    return TextFilterView(
      parentIdentifier: parentIdentifier,
      filter: defaultTextSearchFilter,
    );
  }
}

class FiltersView extends ConsumerStatefulWidget {
  const FiltersView({
    required this.parentIdentifier,
    super.key,
    this.filters,
  });
  final List<CLFilter<CLMedia>>? filters;
  final String parentIdentifier;

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
                    parentIdentifier: widget.parentIdentifier,
                    filter: filter,
                  ),
                FilterType.booleanFilter => throw UnimplementedError(),
                FilterType.dateFilter => throw UnimplementedError(),
                FilterType.ddmmyyyyFilter => DDMMYYYYFilterViewRow(
                    filter: filter,
                    identifier: widget.parentIdentifier,
                  ),
                FilterType.enumFilter => EnumFilterViewRow(
                    filter: filter,
                    identifier: widget.parentIdentifier,
                  ),
              },
            ),
      ],
    );
  }
}
