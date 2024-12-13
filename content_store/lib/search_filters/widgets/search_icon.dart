import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filters.dart';

class SearchIcon extends ConsumerWidget {
  const SearchIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(filtersProvider.select((e) => e.editing));

    return CLButtonIcon.small(
      isEditing ? clIcons.searchOpened : clIcons.searchRequest,
      onTap: () => ref.read(filtersProvider.notifier).toggleEdit(),
    );
  }
}