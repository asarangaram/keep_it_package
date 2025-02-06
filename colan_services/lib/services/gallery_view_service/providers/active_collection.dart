import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeCollectionProvider = StateProvider<int?>((ref) {
  return null;
});

enum MainViews { page, grid }

final currView = StateProvider<MainViews>((ref) {
  return MainViews.page;
});

final currPageIndex = StateProvider<int>((ref) {
  return 0;
});
