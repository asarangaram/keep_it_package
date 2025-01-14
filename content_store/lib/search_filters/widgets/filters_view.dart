import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../providers/filters.dart';
import 'filter_view.dart';
import 'text_filter.dart';

class SearchOptions extends ConsumerStatefulWidget {
  const SearchOptions({super.key, this.maxHeight = 300});
  final double maxHeight;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => SearchOptionsState();
}

class SearchOptionsState extends ConsumerState<SearchOptions> {
  double? height;
  GlobalKey globalKey = GlobalKey();
  final ScrollController controller = ScrollController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool minimize = false;

  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(filtersProvider.select((e) => e.editing));
    final filters = ref.watch(filtersProvider);
    final additionalFilters = filters.filters;
    final hasFilter = additionalFilters != null &&
        additionalFilters.isNotEmpty &&
        additionalFilters.every((e) => e.enabled);

    final hide = !isExpanded && !hasFilter;

    final unusedFilters = filters.unusedFilters;
    final defaultTextSearchFilter = filters.defaultTextSearchFilter;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          globalKey.currentContext?.findRenderObject()! as RenderBox?;
      final size = renderBox?.size;

      if (size == null) {
        setState(() {
          height = 0;
        });
      } else if (height != size.height) {
        height = size.height;
        setState(() {});
      }
    });

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextFilterView(
                    filter: defaultTextSearchFilter,
                  ),
                ),
                PopupMenuButton<CLFilter<CLMedia>>(
                  onSelected: (CLFilter<CLMedia> item) {
                    ref.read(filtersProvider.notifier).addFilter(item);
                  },
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 12),
                  icon: const Icon(Icons.filter_alt_outlined),
                  iconColor: unusedFilters.isEmpty
                      ? Theme.of(context).disabledColor
                      : null,
                  iconSize: 24,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<CLFilter<CLMedia>>>[
                    for (final filter in unusedFilters)
                      PopupMenuItem<CLFilter<CLMedia>>(
                        value: filter,
                        child: Text(filter.name),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (hide)
            const SizedBox.shrink()
          else
            Card(
              elevation: 8,
              //  color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  2,
                ), // Adjust the border radius as needed
              ),

              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        SizeTransition(
                  sizeFactor: animation,
                  child: child,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (hasFilter && !minimize) ...[
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(filtersProvider.notifier)
                                    .clearFilters();
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
                    if (!minimize)
                      if (height == null)
                        SizedBox(
                          height: 200,
                          child: FittedBox(
                            child: SearchOptions0(
                              key: globalKey,
                              filters: additionalFilters,
                            ),
                          ),
                        )
                      else if (height! > widget.maxHeight)
                        SizedBox(
                          height: widget.maxHeight,
                          child: Scrollbar(
                            controller: controller,
                            child: SingleChildScrollView(
                              controller: controller,
                              child: SearchOptions0(
                                key: globalKey,
                                filters: additionalFilters,
                              ),
                            ),
                          ),
                        )
                      else
                        SearchOptions0(
                          key: globalKey,
                          filters: additionalFilters,
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchOptions0 extends ConsumerStatefulWidget {
  const SearchOptions0({
    super.key,
    this.filters,
  });
  final List<CLFilter<CLMedia>>? filters;

  @override
  ConsumerState<SearchOptions0> createState() => SearchOptions0State();
}

class SearchOptions0State extends ConsumerState<SearchOptions0> {
  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;
    final hasFilter = filters != null &&
        filters.isNotEmpty &&
        filters.every((e) => e.enabled);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasFilter) ...filters.map((filter) => FilterView(filter: filter)),
      ],
    );
  }
}
