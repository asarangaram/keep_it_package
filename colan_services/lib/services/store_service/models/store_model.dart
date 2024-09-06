// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_services/services/storage_service/models/file_system/models/cl_directories.dart';
import 'package:colan_services/services/store_service/extensions/list.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

@immutable
class StoreModel {
  const StoreModel({
    required this.collectionList,
    required this.mediaList,
    required this.directories,
  });
  final List<Collection> collectionList;
  final List<CLMedia> mediaList;
  final CLDirectories directories;

  List<Collection> getCollections({bool excludeEmpty = true}) {
    if (excludeEmpty) {
      return collectionList
          .where(
            (c) => mediaList.any((e) => e.collectionId == c.id),
          )
          .toList();
    }
    return collectionList;
  }

  Collection? getCollectionById(int? id) {
    return null;
  }

  List<CLMedia> getStaleMedia() {
    return mediaList.where((e) => e.isHidden ?? false).toList();
  }

  List<CLMedia> getPinnedMedia() {
    return mediaList.where((e) => e.pin != null).toList();
  }

  List<CLMedia> getDeletedMedia() {
    return mediaList.where((e) => e.isDeleted ?? false).toList();
  }

  CLMedia? getMediaById(int? id) {
    if (id == null) return null;
    return mediaList.where((e) => e.id == id).firstOrNull;
  }

  List<CLMedia> getMediaMultipleByIds(List<int> idList) {
    return mediaList.where((e) => idList.contains(e.id)).toList();
  }

  List<CLMedia> getMediaByCollectionId(
    int? collectionId, {
    int maxCount = 0,
    bool isRandom = false,
  }) {
    if (collectionId == null) return [];

    final media =
        mediaList.where((e) => e.collectionId == collectionId).toList();

    if (maxCount > 0) {
      if (isRandom) {
        return media.pickRandomItems(maxCount);
      }
      return media.firstNItems(maxCount);
    }

    return media;
  }

  String getText(CLMedia? media) {
    return '';
  }

  Uri getValidMediaUri(CLMedia? media) {
    return Uri.file('');
  }

  Uri getValidPreviewUri(CLMedia? media) {
    return Uri.file('');
  }

  Future<String> createTempFile({required String ext}) async {
    return '';
  }

  StoreModel copyWith({
    List<Collection>? collectionList,
    List<CLMedia>? mediaList,
    CLDirectories? directories,
  }) {
    return StoreModel(
      collectionList: collectionList ?? this.collectionList,
      mediaList: mediaList ?? this.mediaList,
      directories: directories ?? this.directories,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'StoreModel(collectionList: $collectionList, mediaList: $mediaList, directories: $directories)';

  @override
  bool operator ==(covariant StoreModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.collectionList, collectionList) &&
        listEquals(other.mediaList, mediaList) &&
        other.directories == directories;
  }

  @override
  int get hashCode =>
      collectionList.hashCode ^ mediaList.hashCode ^ directories.hashCode;
}
