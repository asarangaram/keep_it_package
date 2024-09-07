// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:colan_services/services/storage_service/models/file_system/models/cl_directories.dart';
import 'package:colan_services/services/store_service/extensions/list.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../sharing_service/models/share_files.dart';

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

  Iterable<Collection> get validCollection =>
      collectionList.where((e) => !e.label.startsWith('***'));

  List<Collection> getCollections({bool excludeEmpty = true}) {
    if (excludeEmpty) {
      return validCollection
          .where(
            (c) => mediaList.any((e) => e.collectionId == c.id),
          )
          .toList();
    }
    return validCollection.toList();
  }

  Collection? getCollectionById(int? id) {
    if (id == null) return null;
    return collectionList.where((e) => e.id == id).firstOrNull;
  }

  Collection? getCollectionByLabel(String label) {
    return collectionList.where((e) => e.label == label).firstOrNull;
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

  int? getMediaIndexById(int? id) {
    if (id == null) return null;
    return mediaList.indexWhere((e) => e.id == id);
  }

  CLMedia? getMediaByMD5(String md5String) {
    return mediaList.where((e) => e.md5String == md5String).firstOrNull;
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
    if (media?.type != CLMediaType.text) return '';
    final uri = getMediaUri(media!);
    if (uri.scheme == 'file') {
      final path = uri.path;

      return File(path).existsSync()
          ? File(path).readAsStringSync()
          : 'Content Missing. File not found';
    }
    throw UnimplementedError('Implement for Server');
  }

  Uri getPreviewUri(CLMedia media) {
    return Uri.file(getPreviewAbsolutePath(media));
  }

  Uri getMediaUri(CLMedia media) {
    return Uri.file(getMediaAbsolutePath(media));
  }

  String getPreviewAbsolutePath(CLMedia media) {
    return p.setExtension(
      p.join(
        directories.media.pathString, // FIX ME preview directory
        '${media.md5String}_tn',
      ),
      '.jpeg',
    );
  }

  String getMediaAbsolutePath(CLMedia media) => p.setExtension(
        p.join(
          directories.media.path.path,
          media.md5String,
        ),
        media.fExt,
      );

  Future<String> createTempFile({required String ext}) async {
    final dir = directories.download.path; // FIXME temp Directory
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }

  Future<bool?> shareMedia(
    BuildContext context,
    List<CLMedia> media,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      media.map((e) => getMediaUri(e).path).toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
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
