import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/media_grouper.dart';

final groupMethodProvider = StateProvider<GroupBy>((ref) {
  return const GroupBy();
});
