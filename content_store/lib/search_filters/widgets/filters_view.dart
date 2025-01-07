import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filters.dart';
import 'add_new_filter.dart';
import 'filter_view.dart';

class SearchOptions extends ConsumerStatefulWidget {
  const SearchOptions({super.key});

  @override
  ConsumerState<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends ConsumerState<SearchOptions> {
  bool minimize = false;
  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(filtersProvider.select((e) => e.editing));
    final filters = ref.watch(filtersProvider.select((e) => e.filters));
    final hasFilter = filters != null &&
        filters.isNotEmpty &&
        filters.every((e) => e.enabled);
    final hide = !isExpanded && !hasFilter;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          SizeTransition(
        sizeFactor: animation,
        child: child,
      ),
      child: hide
          ? const SizedBox.shrink()
          : Card(
              elevation: 8,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  2,
                ), // Adjust the border radius as needed
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasFilter) ...[
                          TextButton(
                            onPressed: () {
                              ref.read(filtersProvider.notifier).clearFilters();
                            },
                            child: const Text(
                              'Clear Search',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                        Align(
                          alignment: Alignment.topRight,
                          child: CLButtonIcon.tiny(
                            !hasFilter
                                ? Icons.close
                                : minimize
                                    ? Icons.arrow_drop_down_sharp
                                    : Icons.arrow_drop_up_sharp,
                            onTap: () {
                              if (!hasFilter) {
                                ref
                                    .read(filtersProvider.notifier)
                                    .disableEdit();
                              } else {
                                setState(() {
                                  minimize = !minimize;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!minimize && hasFilter)
                    ...filters.map((filter) => FilterView(filter: filter)),
                  if (!minimize) const AddNewFilter(),
                ],
              ),
            ),
    );
  }
}
