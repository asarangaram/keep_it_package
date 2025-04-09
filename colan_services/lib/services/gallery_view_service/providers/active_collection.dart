import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

final activeCollectionProvider = StateProvider<StoreEntity?>((ref) {
  return null;
});

enum MainViews { page, grid }

final currView = StateProvider<MainViews>((ref) {
  return MainViews.page;
});

final currPageIndex = StateProvider<int>((ref) {
  return 0;
});
