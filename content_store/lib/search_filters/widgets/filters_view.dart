import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../providers/filters.dart';
import 'add_new_filter.dart';
import 'ddmmyyyy_filter_view.dart';
import 'enum_filter_view.dart';

class ShowOrHideSearchOption extends ConsumerWidget {
  const ShowOrHideSearchOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(filtersProvider.select((e) => e.editing));

    return CLButtonIcon.small(
      isEditing ? clIcons.searchOpened : clIcons.searchRequest,
      onTap: () => ref.read(filtersProvider.notifier).toggleEdit(),
    );
  }
}

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

    final noFilter =
        filters == null || filters.isEmpty || filters.every((e) => !e.enabled);
    final hide = !isExpanded && noFilter;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      },
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
                        Align(
                          alignment: Alignment.topRight,
                          child: CLButtonIcon.tiny(
                            noFilter
                                ? Icons.close
                                : minimize
                                    ? Icons.arrow_drop_down_sharp
                                    : Icons.arrow_drop_up_sharp,
                            onTap: () {
                              if (noFilter) {
                                ref
                                    .read(filtersProvider.notifier)
                                    .disableEdit();
                              } else {
                                setState(() {
                                  minimize = !minimize;
                                });
                                //ref.read(filtersProvider.notifier).toggleEdit();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!minimize) ...[
                    if (!noFilter)
                      ...filters.map((filter) => FilterView(filter: filter)),
                    const AddNewFilter(),
                  ],
                ],
              ),
            ),
    );
  }
}

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
                FilterType.stringFilter => throw UnimplementedError(),
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

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = size.width // Set the thickness
      ..style = PaintingStyle.stroke;

    const gap = 3; // Gap between dots
    const dotWidth = 5; // Width of each dot
    print(size);
    for (var y = 0; y < size.height; y += dotWidth + gap) {
      canvas.drawLine(
        Offset(size.width / 2, y.toDouble()),
        Offset(size.width / 2, y.toDouble() + dotWidth),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
