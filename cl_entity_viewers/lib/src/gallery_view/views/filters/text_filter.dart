import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/models/viewer_entity_mixin.dart';
import '../../models/filter/base_filter.dart';
import '../../models/filter/string_filter.dart';
import '../../providers/media_filters.dart';

class TextFilterView extends ConsumerStatefulWidget {
  const TextFilterView({
    required this.filter,
    required this.parentIdentifier,
    super.key,
  });
  final CLFilter<ViewerEntityMixin> filter;
  final String parentIdentifier;

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
      text: (widget.filter as StringFilter<ViewerEntityMixin>).query,
    );
    controller.addListener(updateFilter);
    super.initState();
  }

  void updateFilter() {
    ref
        .read(mediaFiltersProvider(widget.parentIdentifier).notifier)
        .updateDefautTextSearchFilter(
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
      trailing: controller.text.isNotEmpty
          ? ShadButton(
              width: CLScaleType.verySmall.iconSize,
              height: CLScaleType.verySmall.iconSize,
              padding: EdgeInsets.zero,
              decoration: const ShadDecoration(
                secondaryBorder: ShadBorder.none,
                secondaryFocusedBorder: ShadBorder.none,
              ),
              child: Icon(
                clIcons.textClear,
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
