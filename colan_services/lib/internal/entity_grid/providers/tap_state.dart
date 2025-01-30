import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabScrollPositionProvider =
    StateProvider.family<double, String>((ref, tabIdentifier) {
  return 0;
});

final currTabProvider =
    StateProvider.family<String, String>((ref, viewIdentifier) {
  return 'Media';
});

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
