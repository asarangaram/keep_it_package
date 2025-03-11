import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';

/* class Identifiers {
  static String tabIdentifier(String parent, String tabName) =>
      '$parent $tabName';
}

class UniqueID {
  static String of(List<String> tags) => tags.join(' ');
}

final currTabIdProvider =
    StateProvider.family<String, String>((ref, viewIdentifier) {
  final currTabName = ref.watch(currTabProvider(viewIdentifier));
  return UniqueID.of([viewIdentifier, currTabName]);
});
 */

// State perView
final currTabProvider =
    StateProvider.family<String, ViewIdentifier>((ref, viewIdentifier) {
  return 'Media';
});

// State per Tab
final selectModeProvider =
    StateProvider.family<bool, TabIdentifier>((ref, identifier) {
  return false;
});
final tabScrollPositionProvider =
    StateProvider.family<double, TabIdentifier>((ref, identifier) {
  return 0;
});
