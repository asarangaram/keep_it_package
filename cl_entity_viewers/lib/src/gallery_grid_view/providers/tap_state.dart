import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';

final currTabProvider =
    StateProvider.family<String, ViewIdentifier>((ref, viewIdentifier) {
  return 'Media';
});
