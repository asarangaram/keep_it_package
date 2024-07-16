import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cl_media.dart';
import 'cl_note.dart';
import 'collection.dart';

abstract class Store {
  /// upsertCollection - introduce NULL return
  Future<Collection> upsertCollection(Collection collection);
  Future<CLMedia?> upsertMedia(CLMedia media);
  Future<CLNote?> upsertNote(CLNote note, List<CLMedia> mediaList);

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media, {required bool permanent});
  Future<void> deleteNote(CLNote note);

  Future<void> togglePin(
    CLMedia media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  });
  Future<void> pinMediaMultiple(
    List<CLMedia> media, {
    required Future<String?> Function(
      CLMedia media, {
      required String title,
      String? desc,
    }) onPin,
    required Future<bool> Function(String id) onRemovePin,
  });
  Future<void> unpinMediaMultiple(
    List<CLMedia> media, {
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  });

  Future<List<Object?>?> rawQuery(String query);

  Future<List<Object?>?> getDBRecords();

  Future<Collection?> getCollectionByLabel(String label);
  Future<CLMedia?> getMediaByMD5(String md5String);
  Future<List<CLNote>?> getNotesByMediaID(int noteId);

  Future<void> reloadStore(WidgetRef ref);
}
