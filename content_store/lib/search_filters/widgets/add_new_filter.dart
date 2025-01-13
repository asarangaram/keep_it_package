import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filters.dart';
import '../providers/filters.dart';
import 'text_filter.dart';

class AddNewFilter extends ConsumerStatefulWidget {
  const AddNewFilter({
    super.key,
  });

  @override
  ConsumerState<AddNewFilter> createState() => AddNewFilterState();
}

class AddNewFilterState extends ConsumerState<AddNewFilter> {
  CLFilter<CLMedia>? currentValue;
  late final String maxString;
  @override
  void initState() {
    maxString = SearchFilters.allFilters
        .reduce((a, b) => a.name.length >= b.name.length ? a : b)
        .name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final unusedFilters =
        ref.watch(filtersProvider.select((e) => e.unusedFilters));
    if (unusedFilters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const CLText.small('Add a search option'),
            const SizedBox(
              width: 16,
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              child: DropdownButton<CLFilter<CLMedia>>(
                isDense: true,
                elevation: 0,
                alignment: AlignmentDirectional.center,
                borderRadius: BorderRadius.zero,
                padding: EdgeInsets.zero,
                onChanged: (CLFilter<CLMedia>? item) {
                  if (item != null) {
                    ref.read(filtersProvider.notifier).addFilter(item);
                    setState(() {
                      currentValue = null;
                    });
                  }
                },
                value: currentValue,
                items: [
                  for (final filter in unusedFilters)
                    DropdownMenuItem<CLFilter<CLMedia>>(
                      value: filter,
                      child: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          CLText.tiny(
                            maxString,
                            color: Colors.transparent,
                          ),
                          CLText.tiny(filter.name),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
