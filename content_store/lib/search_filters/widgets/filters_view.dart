import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filters.dart';
import '../providers/filters.dart';

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

class SearchOptions extends ConsumerWidget {
  const SearchOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(filtersProvider.select((e) => e.editing));
    return AnimateSearchOptions(
      child: Card(
        elevation: 8,
        color: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(2), // Adjust the border radius as needed
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
                      isExpanded
                          ? Icons.arrow_drop_down_sharp
                          : Icons.arrow_drop_up_sharp,
                      onTap: () =>
                          ref.read(filtersProvider.notifier).toggleEdit(),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AddNewFilterDropDown(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AddNewFilter extends ConsumerWidget {
  const AddNewFilter({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unusedFilters =
        ref.watch(filtersProvider.select((e) => e.unusedFilters));
    if (unusedFilters.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: PopupMenuButton<CLFilter<CLMedia>>(
          onSelected: (CLFilter<CLMedia> item) {
            ref.read(filtersProvider.notifier).addFilter(item);
          },
          padding: EdgeInsets.zero,
          offset: const Offset(0, 12),
          icon: const Icon(Icons.add_circle),
          iconColor: Colors.white,
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
      ),
    );
  }
}

class AddNewFilterDropDown extends ConsumerStatefulWidget {
  const AddNewFilterDropDown({
    super.key,
  });

  @override
  ConsumerState<AddNewFilterDropDown> createState() =>
      _AddNewFilterDropDownState();
}

class _AddNewFilterDropDownState extends ConsumerState<AddNewFilterDropDown> {
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
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CLText.small('Add a search option'),
          const SizedBox(
            width: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DropdownButton<CLFilter<CLMedia>>(
              isDense: true,
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
                      alignment: Alignment.center,
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
    );
  }
}

class AnimateSearchOptions extends ConsumerStatefulWidget {
  const AnimateSearchOptions({required this.child, super.key});
  final Widget child;

  @override
  AnimatedHeightWidgetState createState() => AnimatedHeightWidgetState();
}

class AnimatedHeightWidgetState extends ConsumerState<AnimateSearchOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: child,
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}
