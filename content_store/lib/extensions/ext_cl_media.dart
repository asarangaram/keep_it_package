import 'package:store/store.dart';

extension StoreExtCollection on Collection {
  static Collection collectionFromServerMap(
    Collection? collectionInDB,
    Map<String, dynamic> map,
  ) {
    map['id'] = collectionInDB?.id;
    map['haveItOffline'] = (collectionInDB?.haveItOffline ?? false) ? 1 : 0;
    map['isDeleted'] ??= 0;
    map['isEdited'] = 0;
    return Collection.fromMap(map);
  }
}

extension StoreExtCLMedia on CLMedia {
  /// Same like fromMap but uses missing info from another media
  static CLMedia mediaFromServerMap(
    CLMedia? mediaInDB,
    Map<String, dynamic> map,
  ) {
    /// FIXME: Handle Pin
    /* /// if the media is pinned already,
    ///   we can't proceed here as the pin need to be updated.
    ///   we can't update pin on mobile devices without user action
    if (mediaInDB?.pin != null) {
      // Mark conflict
      return mediaInDB!;
    } */

    /* /// If we have found by serverUID, and if it is Deleted
    /// the delete message is yet to upload, hence we can't update this media.
    if (mediaInDB?.serverUID != null && (mediaInDB!.isDeleted ?? false)) {
      return mediaInDB;
    } */

    /* /// Check if the media in server is changed by comparing md5
    /// if media is changed / different
    ///   A. It was locally changed, and upload didn't happen correctly or
    ///       yet to be scheduled. In this case, mark it as conflict
    ///       abd return
    if (mediaInDB?.md5String != map['md5String'] &&
        (mediaInDB?.isEdited ?? false)) {
      // Mark conflict
      return mediaInDB!;
    } */

    map['id'] = mediaInDB?.id;
    if (mediaInDB?.md5String == map['md5String']) {
      map['isPreviewCached'] = mediaInDB!.isPreviewCached ? 1 : 0;
      map['isMediaCached'] = mediaInDB.isMediaCached ? 1 : 0;
      map['isMediaOriginal'] = mediaInDB.isMediaOriginal ? 1 : 0;
    } else {
      map['isPreviewCached'] = 0;
      map['isMediaCached'] = 0;
      map['isMediaOriginal'] = 0;
    }

    map['previewLog'] = null;
    map['mediaLog'] = null;
    // if not marked, assume it is not deleted
    map['isDeleted'] ??= 0;
    // Media from server won't be hidden locally
    map['isHidden'] = 0;
    map['pin'] = null;
    map['isEdited'] = 0;
    map['haveItOffline'] = mediaInDB?.haveItOffline == null
        ? null
        : (mediaInDB!.haveItOffline! ? 1 : 0);
    map['mustDownloadOriginal'] =
        (mediaInDB?.mustDownloadOriginal ?? false) ? 1 : 0;
    return CLMedia.fromMap(map);
  }
}

extension StoreExtCLMediaList on List<CLMedia> {
  Map<String, List<CLMedia>> filterByDate() {
    final filterredMedia = <String, List<CLMedia>>{};
    final noDate = <CLMedia>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.originalDate != null) {
        formattedDate = entry.originalDate!.toDisplayFormat(dataOnly: true);
        if (!filterredMedia.containsKey(formattedDate)) {
          filterredMedia[formattedDate] = [];
        }
        filterredMedia[formattedDate]!.add(entry);
      } else {
        formattedDate = '${entry.createdDate.toDisplayFormat(dataOnly: true)} '
            '(upload date)';
      }
      if (!filterredMedia.containsKey(formattedDate)) {
        filterredMedia[formattedDate] = [];
      }
      filterredMedia[formattedDate]!.add(entry);
    }
    if (noDate.isNotEmpty) {
      filterredMedia['No Date'] = noDate;
    }

    return filterredMedia;
  }
}

extension FilenameExtOnCLMedia on CLMedia {
  String get previewFileName => '${md5String}_tn.jpeg';
  String get mediaFileName => '$md5String$fExt';

  String? get mediaEndPoint => serverUID == null
      ? null
      : '/media/$serverUID/download?isOriginal=$mustDownloadOriginal';
  String? get previewEndPoint =>
      serverUID == null ? null : '/media/$serverUID/preview';

  String? get mediaPostEndPoint => '/media';
}
