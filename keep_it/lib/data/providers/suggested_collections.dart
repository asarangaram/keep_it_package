import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/suggested_collections.dart';

final availableSuggestionsProvider =
    StateProvider.family<List<Collection>, List<Collection>?>(
        (ref, existingCollections) {
  if (existingCollections == null) return suggestedCollections;

  return suggestedCollections.where((element) {
    return !existingCollections.map((e) => e.label).contains(element.label);
  }).toList();
});
