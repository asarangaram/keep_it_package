import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 200,
        height: 50,
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Search',
          ),
          onChanged: (value) {
            ref.read(filtersProvider.notifier).updateFilter(
                  widget.filter,
                  'query',
                  controller.text,
                );
          },
        ),
      ),
    );
  }
}
