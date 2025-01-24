import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeCollectionProvider = StateProvider<int?>((ref) {
  return null;
});
final mainPageIdentifierProvider = StateProvider<String>((ref) {
  final collectionId = ref.watch(activeCollectionProvider);
  return 'Gallery Collection $collectionId';
});
