import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

abstract class ContentStore {
  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> existingItems,
      required List<CLMedia> newItems,
    }) onDone,
  });

  List<Collection> getCollections({bool excludeEmpty = true});
  Collection? getCollectionById(int? id);

  List<CLMedia> getStaleMedia();
  List<CLMedia> getPinnedMedia();
  List<CLMedia> getDeletedMedia();

  List<CLMedia> getMediaByCollectionId(
    int? collectionId, {
    int maxCount = 0,
    bool isRandom = false,
  });
  CLMedia? getMediaById(int? id);

  int getMediaCountByCollectionId(int? collectionId);
  List<CLMedia> getMediaMultipleByIds(List<int> idList);

  Stream<Progress> moveToCollectionStream({
    required List<CLMedia> media,
    required Collection collection,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  });

  Future<bool> deleteMediaMultiple(Set<int> ids2Delete);

  List<GalleryGroup<CLMedia>> galleryMap(List<CLMedia> mediaList);

  bool hasMediaFile(CLMedia media);

  Future<bool> deleteCollectionById(
    int collectionId,
  );
  Future<bool> deleteMediaById(int id);
  Future<bool> permanentlyDeleteMediaMultiple(Set<int> ids2Delete);
  Future<bool> restoreMediaMultiple(Set<int> ids2Delete);

  // This should not be in this way.
  Future<bool?> shareMedia(
    BuildContext context,
    List<CLMedia> media,
  );
  Future<bool> togglePin(CLMedia media);
  Future<bool> togglePinMultiple(List<CLMedia> media);

  String getText(CLMedia? media);

  Future<String> createTempFile({required String ext});

  Future<Collection> upsertCollection(
    Collection collection,
  );

  Future<CLMedia?> upsertMedia(
    String path,
    CLMediaType type, {
    bool? isAux,
    String? ref,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
    bool? isDeleted,
    bool? isHidden,
    String? pin,
    int? collectionId,
    int? id,
    bool? isPreviewCached,
    bool? isMediaCached,
    String? previewLog,
    String? mediaLog,
    bool? isMediaOriginal,
    int? serverUID,
    bool? isEdited,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
    List<CLMedia>? parents,
  });
  Future<CLMedia> replaceMedia(
    String path, {
    required CLMedia media,
  });
  Future<CLMedia> cloneAndReplaceMedia(
    String path, {
    required CLMedia media,
  });

  void onRefresh();
}
