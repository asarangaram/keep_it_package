import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';
import 'media_grouper.dart';
import 'media_filters.dart';
import '../models/view_modifier.dart';

final viewModifiersProvider =
    StateProvider.family<List<ViewModifier>, ViewIdentifier>(
        (ref, viewIdentifier) {
  final items = [
    ref.watch(mediaFiltersProvider(viewIdentifier.parentID)),
    ref.watch(
      groupMethodProvider(viewIdentifier.parentID),
    ),
  ];
  return items;
});
