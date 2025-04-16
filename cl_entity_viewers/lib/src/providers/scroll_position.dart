import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';

final tabScrollPositionProvider =
    StateProvider.family<double, TabIdentifier>((ref, identifier) {
  return 0;
});
