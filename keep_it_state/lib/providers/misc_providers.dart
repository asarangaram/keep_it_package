import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeCollectionProvider = StateProvider<int?>((ref) {
  return null;
});
final mainPageIdentifierProvider = StateProvider<String>((ref) {
  final collectionId = ref.watch(activeCollectionProvider);
  return 'Gallery Collection $collectionId';
});
final selectModeProvider =
    StateProvider.family<bool, String>((ref, identifier) {
  return false;
});


