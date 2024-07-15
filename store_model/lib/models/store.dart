import 'dart:io';

import 'cl_media.dart';
import 'cl_note.dart';
import 'collection.dart';

abstract class Store {
  Future<Collection> upsertCollection({
    required Collection collection,
  });
  Future<CLMedia?> upsertMedia({
    required int collectionId,
    required CLMedia media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  });
  Future<void> upsertMediaMultiple({
    required int collectionId,
    required List<CLMedia>? media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  });
  Future<CLMedia?> setCollection4Media({
    required int collectionId,
    required CLMedia media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  });
  Future<void> setCollection4MultipleMedia({
    required int collectionId,
    required List<CLMedia>? media,
    required Future<CLMedia> Function(
      CLMedia media, {
      required String targetDir,
    }) onPrepareMedia,
  });

  Future<void> deleteCollection(
    Collection collection, {
    required Future<void> Function(File file) onDeleteFile,
  });
  Future<void> deleteMedia(
    CLMedia media, {
    required Future<void> Function(File file) onDeleteFile,
    required Future<bool> Function(String id) onRemovePin,
  });
  Future<void> deleteMediaMultiple(
    List<CLMedia> media, {
    required Future<void> Function(File file) onDeleteFile,
    required Future<bool> Function(List<String> ids) onRemovePinMultiple,
  });
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
  Future<CLNote> upsertNote(
    CLNote note,
    List<CLMedia> mediaList, {
    required Future<CLNote> Function(
      CLNote note, {
      required String targetDir,
    }) onSaveNote,
  });
  Future<List<Object?>?> rawQuery(
    String query,
  );

  Future<void> deleteNote(
    CLNote note, {
    required Future<void> Function(File file) onDeleteFile,
  });

  Future<List<Object?>?> getDBRecords();
  Future<Collection?> getCollectionByLabel(String label);
  Future<CLMedia?> getMediaByMD5(
    String md5String,
  );

  Future<void> reloadStore(dynamic refObject);
}
