import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'media_grouper.dart';
import 'media_filters.dart';
import '../models/view_modifier.dart';

final viewModifiersProvider = StateProvider<List<ViewModifier>>((
  ref,
) {
  final items = [
    ref.watch(mediaFiltersProvider),
    ref.watch(
      groupMethodProvider,
    ),
  ];
  return items;
});
