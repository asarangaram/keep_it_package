import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/string_filter.dart';
import '../providers/filters.dart';

class TextFilterView extends ConsumerStatefulWidget {
  const TextFilterView({required this.filter, super.key});
  final CLFilter<CLMedia> filter;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextFilterViewState();
}

class _TextFilterViewState extends ConsumerState<TextFilterView> {
  late final TextEditingController controller;

  @override
  void initState() {
    if (widget.filter.filterType != FilterType.stringFilter) {
      throw Exception('filter is not EnumFilter');
    }
    controller = TextEditingController(
      text: (widget.filter as StringFilter<CLMedia>).query,
    );
    controller.addListener(updateFilter);
    super.initState();
  }

  void updateFilter() {
    ref.read(filtersProvider.notifier).updateDefautTextSearchFilter(
          controller.text,
        );
  }

  @override
  void dispose() {
    controller
      ..removeListener(updateFilter)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: controller,
      placeholder: const Text('Search Media'),
      suffix: controller.text.isNotEmpty
          ? ShadButton(
              width: CLScaleType.verySmall.iconSize,
              height: CLScaleType.verySmall.iconSize,
              padding: EdgeInsets.zero,
              decoration: const ShadDecoration(
                secondaryBorder: ShadBorder.none,
                secondaryFocusedBorder: ShadBorder.none,
              ),
              icon: const Icon(
                LucideIcons.x,
              ),
              onPressed: () {
                controller.clear();
              },
            )
          : null,
    );
    /* return SizedBox(
      width: 200,
      height: 50,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Search',
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: CLButtonIcon.tiny(
              Icons.backspace_outlined,
              onTap: () {
                controller.clear();
              },
            ),
          ),
        ),
        //  autofocus: true,
      ),
    ); */
  }
}
