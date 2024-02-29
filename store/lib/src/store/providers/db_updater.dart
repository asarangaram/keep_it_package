/* 
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path_provider/path_provider.dart';

import '../models/resources.dart';
import '../providers/resources.dart';


class DBUpdaterNotifier extends StateNotifier<int> {
  DBUpdaterNotifier(this.ref) : super(0);
  Ref ref;
  String? _pathPrefix;
  /* Future<Database> get db async =>
      (await ref.watch(dbManagerProvider.future)).db; */
  Future<String> get pathPrefix async =>
      _pathPrefix ??= (await getApplicationDocumentsDirectory()).path;

  Future<Resources> get resources async =>
      await ref.watch(resourcesProvider.future);

  /* void refreshProviders() {
    state = state + 1;
  } */

  Future<void> upsertCollection(
    Collection collection,
    List<Tag>? tags,
  ) async {
    (await resources).upsertCollection(collection, tags);
  }

  /// This function is used

  /// to create new collection with media and tags
  /// to update existing collection with replace tags and media
  /// don't use this for
  /// important: this function replaces the existing tags list
  /// which is used in the forms.
  /// 1. to insert tags
  /// 2. to delete tags.
  Stream<Progress> upsertCollectionWithMedia({
    required Collection collection,
    required List<CLMedia> media,
    required void Function() onDone,
    List<Tag>? newTagsListToReplace,
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async* {
    final stream = (await resources)
        .upsertCollectionWithMedia(collection, newTagsListToReplace, media, () {
      onDone.call();
    });

    await for (final element in stream) {
      yield element;
    }
  }

  Future<Tag> upsertTag(Tag tag) async {
    /* final tagWithID = tag.upsert(await db);

    return tagWithID; */
    return const Tag(label: 'Unexepcted');
  }

  Future<void> deleteCollection(Collection collection) async {
    await (await resources).deleteCollection(collection);
  }

  Future<void> deleteCollectionMultiple(List<Collection> collections) async {
    await (await resources).deleteCollectionMultiple(collections);
  }

  Future<void> deleteItem(CLMedia item) async {
    await (await resources).deleteMedia(item);
  }

  Future<void> deleteItems(List<CLMedia> items) async {
    await (await resources).deleteMediaMultiple(items);
  }
}

final dbUpdaterNotifierProvider =
    StateNotifierProvider<DBUpdaterNotifier, int>((ref) {
  return DBUpdaterNotifier(ref);
});
 */
