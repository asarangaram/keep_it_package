import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../../media_grouper/providers/media_grouper.dart';
import '../../search_filters/providers/media_filters.dart';
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
