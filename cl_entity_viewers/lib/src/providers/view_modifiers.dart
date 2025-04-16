import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';
import 'media_grouper.dart';
import 'media_filters.dart';
import '../models/view_modifier.dart';

final viewModifiersProvider =
    StateProvider.family<List<ViewModifier>, TabIdentifier>(
        (ref, tabIdentifier) {
  final items = [
    ref.watch(mediaFiltersProvider(tabIdentifier.view.parentID)),
    ref.watch(
      groupMethodProvider(tabIdentifier.tabId),
    ),
  ];
  return items;
});
