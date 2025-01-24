import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GroupTypes { none, byOriginalDate }

final groupMethodProvider = StateProvider<GroupTypes>((ref) {
  return GroupTypes.none;
});
