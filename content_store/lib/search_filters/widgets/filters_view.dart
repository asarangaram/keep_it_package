import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../providers/filters.dart';
import 'add_new_filter.dart';
import 'filter_view.dart';

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
    final filters = ref.watch(filtersProvider.select((e) => e.filters));
    final hasFilter = filters != null &&
        filters.isNotEmpty &&
        filters.every((e) => e.enabled);
    final hide = !isExpanded && !hasFilter;
    if (hide) {
      return const SizedBox.shrink();
    }

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

    return Card(
      elevation: 8,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          2,
        ), // Adjust the border radius as needed
      ),
      margin: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) =>
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
                          ref.read(filtersProvider.notifier).disableEdit();
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
            if (!minimize) const AddNewFilter(),
            if (!minimize)
              if (height == null || height! < widget.maxHeight)
                SearchOptions0(
                  key: globalKey,
                  filters: filters,
                )
              else
                SizedBox(
                  height: widget.maxHeight,
                  child: Scrollbar(
                    controller: controller,
                    child: SingleChildScrollView(
                      controller: controller,
                      child: SearchOptions0(
                        key: globalKey,
                        filters: filters,
                      ),
                    ),
                  ),
                ),
          ],
        ),
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
