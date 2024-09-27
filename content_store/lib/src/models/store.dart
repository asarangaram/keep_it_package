import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

extension GalleryMapExt on CLMedias {
  List<GalleryGroup<CLMedia>> get galleryMap => [];
  bool get isNotEmpty => entries.isNotEmpty;
  bool get isEmpty => entries.isEmpty;
}

abstract class DBReader {}

abstract class ContentStore {
  //// Read APIs
  Collections getCollections({bool excludeEmpty = true});
  Collection? getCollectionById(int? id);

  CLMedias getStaleMedia();
  CLMedias getPinnedMedia();
  CLMedias getDeletedMedia();
  CLMedias getMediaByCollectionId(
    int? collectionId, {
    int maxCount = 0,
    bool isRandom = false,
  });
  CLMedia? getMediaById(int? id);
  CLMedias getMediaMultipleByIds(List<int> idList);
  int getMediaCountByCollectionId(int? collectionId);

  String getText(CLMedia? media);

  bool hasMediaFile(CLMedia media);

  Future<bool> deleteCollectionById(int id);
  Future<bool> deleteMediaById(int id);
  Future<bool> deleteMediaMultipleById(Set<int> ids2Delete);
  Future<bool> permanentlyDeleteMediaMultipleById(Set<int> ids2Delete);
  Future<bool> restoreMediaMultipleById(Set<int> ids2Delete);

  Future<bool> togglePinById(int id);
  Future<bool> togglePinMultipleById(Set<int> ids2Delete);

  Future<String> createTempFile({required String ext});

  Future<Collection> upsertCollection(Collection collection);

  Future<CLMedia?> newMedia(
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

  Stream<Progress> moveToCollectionStream({
    required List<CLMedia> media,
    required Collection collection,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  });

  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> existingItems,
      required List<CLMedia> newItems,
    }) onDone,
  });

  void onRefresh();

  // This should not be in this way.
  Future<bool?> shareMedia(
    BuildContext context,
    List<CLMedia> media,
  );
}
