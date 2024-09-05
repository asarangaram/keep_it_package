// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../extensions/list_ext.dart';

@immutable
class MediaWithDetails {
  const MediaWithDetails({
    required this.media,
    required this.preference,
    required this.status,
    required this.notes,
  });
  final CLMedia media;
  final MediaPreference preference;
  final MediaStatus status;
  final List<CLMedia> notes;

  MediaWithDetails copyWith({
    CLMedia? media,
    MediaPreference? preference,
    MediaStatus? status,
    List<CLMedia>? notes,
  }) {
    return MediaWithDetails(
      media: media ?? this.media,
      preference: preference ?? this.preference,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'MediaWithDetails(media: $media, preference: $preference, status: $status, notes: $notes)';
  }

  @override
  bool operator ==(covariant MediaWithDetails other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.media == media &&
        other.preference == preference &&
        other.status == status &&
        listEquals(other.notes, notes);
  }

  @override
  int get hashCode {
    return media.hashCode ^
        preference.hashCode ^
        status.hashCode ^
        notes.hashCode;
  }
}

@immutable
class MediaWithDetailsList {
  const MediaWithDetailsList(
    this.items,
  );
  final List<MediaWithDetails> items;

  MediaWithDetailsList copyWith({
    List<MediaWithDetails>? items,
  }) {
    return MediaWithDetailsList(
      items ?? this.items,
    );
  }

  @override
  String toString() => 'MediaWithDetailsList(items: $items)';

  @override
  bool operator ==(covariant MediaWithDetailsList other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items);
  }

  @override
  int get hashCode => items.hashCode;

  Future<MediaWithDetailsList> upsert(
    MediaWithDetails updated,
  ) async {
    if (updated.media.id == null) {
      throw Exception('missing id. ');
    }

    final currentItemIndex =
        items.indexWhere((e) => e.media.id == updated.media.id);

    if (currentItemIndex == -1) {
      // insert if not present
      return copyWith(items: [...items, updated]);
    } else {
      // update if present
      return copyWith(items: items.replaceNthEntry(currentItemIndex, updated));
    }
  }

  CLMedia? getMedia(int id) {
    return items.where((e) => e.media.id == id).firstOrNull?.media;
  }

  List<CLMedia> getMediaByCollectionId(int? collectionId) {
    return items.where((e) {
      return collectionId == null ||
          e.media.collectionId == collectionId && !e.media.isAux;
    }).toSortedMediaOnly();
  }

  List<CLMedia> getMediaMultiple(List<int> idList) {
    return items.where((e) {
      return idList.contains(e.media.id) && !e.media.isAux;
    }).toSortedMediaOnly();
  }

  List<CLMedia> getPinnedMedia() {
    return items.where((e) {
      return e.media.pin != null &&
          !(e.media.isDeleted ?? false) &&
          !(e.media.isHidden ?? false) &&
          !e.media.isAux;
    }).toSortedMediaOnly();
  }

  List<CLMedia> getStaleMedia() {
    return items.where((e) {
      return (e.media.isHidden ?? false) && !e.media.isAux;
    }).toSortedMediaOnly();
  }

  List<CLMedia> getDeletedMedia() {
    return items.where((e) {
      return (e.media.isDeleted ?? false) && !e.media.isAux;
    }).toSortedMediaOnly();
  }

  List<CLMedia> getNotesByMediaId(int id) {
    return items.where((e) => e.media.id == id).firstOrNull?.notes ?? [];
  }
}
