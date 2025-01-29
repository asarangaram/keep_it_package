import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_grouper.dart';

final groupMethodProvider =
    StateProvider.family<GroupBy, String>((ref, identifer) {
  return const GroupBy();
});
