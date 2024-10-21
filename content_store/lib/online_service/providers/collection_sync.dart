import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CollectionSyncNotifier extends StateNotifier<AsyncValue<Collection>> {
  CollectionSyncNotifier(this.collectionId)
      : super(const AsyncValue.loading()) {
    initialize();
  }
  int collectionId;

  Future<void> initialize() async {}

  Future<void> sync() async {
    // Check if this collection exists online
    //  If not, create a online Collection, and get serverUID
    // using serverUID, get all media found in server.
    // get the media list from DB
  }
  Future<void> removeLocalCopy() async {}
  Future<void> removeServerCopy() async {}
}

final collectionSyncProvider =
    StateNotifierProvider.family<CollectionSyncNotifier, bool, int>(
        (ref, collectionId) {
  return CollectionSyncNotifier(collectionId);
});
