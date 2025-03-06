import 'dart:convert';
import 'dart:math';
import 'package:meta/meta.dart';

import 'cl_entities.dart';
import 'cl_media_base.dart';
import 'cl_media_type.dart';
import 'collection.dart';

@immutable
class CLMedia extends CLMediaBase implements CLEntity {
  const CLMedia._({
    required super.name,
    required super.type,
    required super.fExt,
    required super.collectionId,
    required this.isPreviewCached,
    required this.isMediaCached,
    required this.isMediaOriginal,
    required this.isEdited,
    required this.previewLog,
    required this.mediaLog,
    required this.serverUID,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
    required this.createdDate,
    required this.updatedDate,
    super.ref,
    super.originalDate,
    super.md5String,
    super.isDeleted,
    super.isHidden,
    super.pin,
    super.isAux,
    this.id,
  });
  factory CLMedia.strict({
    required String name,
    required CLMediaType type,
    required String fExt,
    required String? ref,
    required DateTime? originalDate,
    required String? md5String,
    required bool? isDeleted,
    required bool? isHidden,
    required String? pin,
    required int? collectionId,
    required bool isAux,
    required int? id,
    required bool isPreviewCached,
    required bool isMediaCached,
    required String? previewLog,
    required String? mediaLog,
    required bool isMediaOriginal,
    required int? serverUID,
    required bool? isEdited,
    required bool? haveItOffline,
    required bool mustDownloadOriginal,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    final time = DateTime.now();
    return CLMedia._(
      name: name,
      type: type,
      fExt: fExt,
      collectionId: collectionId,
      isPreviewCached: isPreviewCached,
      isMediaCached: isMediaCached,
      isMediaOriginal: isMediaOriginal,
      isEdited: isEdited,
      previewLog: previewLog,
      mediaLog: mediaLog,
      serverUID: serverUID,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
      ref: ref,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      isAux: isAux,
      id: id,
      pin: pin,
      originalDate: originalDate,
      createdDate: createdDate ?? time,
      updatedDate: updatedDate ?? time,
    );
  }

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia.strict(
      name: map['name'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      fExt: map['fExt'] as String? ?? '.unk',
      ref: map['ref'] != null ? map['ref'] as String : null,
      originalDate: map['originalDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['originalDate'] as int)
          : null,
      createdDate:
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      updatedDate:
          DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int),
      md5String: map['md5String'] != null ? map['md5String'] as String : null,
      isDeleted: (map['isDeleted'] as int? ?? 0) != 0,
      isHidden: (map['isHidden'] as int? ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      isAux: (map['isAux'] as int? ?? 0) != 0,
      id: map['id'] != null ? map['id'] as int : null,
      isPreviewCached: (map['isPreviewCached'] as int? ?? 0) != 0,
      isMediaCached: (map['isMediaCached'] as int? ?? 0) != 0,
      previewLog:
          map['previewLog'] != null ? map['previewLog'] as String : null,
      mediaLog: map['mediaLog'] != null ? map['mediaLog'] as String : null,
      isMediaOriginal: (map['isMediaOriginal'] as int? ?? 0) != 0,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      isEdited: map['isEdited'] == null ? null : (map['isEdited'] as int) != 0,
      haveItOffline: map['haveItOffline'] == null
          ? null
          : (map['haveItOffline'] as int) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int? ?? 0) != 0,
    );
  }

  factory CLMedia.fromJson(String source) => CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  final int? id;
  final bool isPreviewCached;
  final bool isMediaCached;
  final String? previewLog;
  final String? mediaLog;
  final bool isMediaOriginal;
  final int? serverUID;
  final bool? isEdited;
  final bool? haveItOffline;
  final bool mustDownloadOriginal;
  final DateTime createdDate;
  final DateTime updatedDate;

  CLMedia _copyWith({
    ValueGetter<String>? name,
    ValueGetter<CLMediaType>? type,
    ValueGetter<String>? fExt,
    ValueGetter<String?>? ref,
    ValueGetter<DateTime?>? originalDate,
    ValueGetter<DateTime?>? createdDate,
    ValueGetter<DateTime?>? updatedDate,
    ValueGetter<String?>? md5String,
    ValueGetter<bool?>? isDeleted,
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<int?>? collectionId,
    ValueGetter<bool>? isAux,
    ValueGetter<int?>? id,
    ValueGetter<bool>? isPreviewCached,
    ValueGetter<bool>? isMediaCached,
    ValueGetter<String?>? previewLog,
    ValueGetter<String?>? mediaLog,
    ValueGetter<bool>? isMediaOriginal,
    ValueGetter<int?>? serverUID,
    ValueGetter<bool?>? isEdited,
    ValueGetter<bool?>? haveItOffline,
    ValueGetter<bool>? mustDownloadOriginal,
  }) {
    return CLMedia.strict(
      name: name != null ? name() : this.name,
      type: type != null ? type() : this.type,
      fExt: fExt != null ? fExt() : this.fExt,
      collectionId: collectionId != null ? collectionId() : this.collectionId,
      isPreviewCached:
          isPreviewCached != null ? isPreviewCached() : this.isPreviewCached,
      isMediaCached:
          isMediaCached != null ? isMediaCached() : this.isMediaCached,
      isMediaOriginal:
          isMediaOriginal != null ? isMediaOriginal() : this.isMediaOriginal,
      isEdited: isEdited != null ? isEdited() : this.isEdited,
      previewLog: previewLog != null ? previewLog() : this.previewLog,
      mediaLog: mediaLog != null ? mediaLog() : this.mediaLog,
      serverUID: serverUID != null ? serverUID() : this.serverUID,
      haveItOffline:
          haveItOffline != null ? haveItOffline() : this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal != null
          ? mustDownloadOriginal()
          : this.mustDownloadOriginal,
      ref: ref != null ? ref() : this.ref,
      originalDate: originalDate != null ? originalDate() : this.originalDate,
      createdDate: createdDate != null ? createdDate() : this.createdDate,
      updatedDate: updatedDate != null ? updatedDate() : this.updatedDate,
      md5String: md5String != null ? md5String() : this.md5String,
      isDeleted: isDeleted != null ? isDeleted() : this.isDeleted,
      isHidden: isHidden != null ? isHidden() : this.isHidden,
      pin: pin != null ? pin() : this.pin,
      isAux: isAux != null ? isAux() : this.isAux,
      id: id != null ? id() : this.id,
    );
  }

  @override
  String toString() {
    return 'CLMedia(id: $id, name: $name, type: $type, fExt: $fExt, ref: $ref, originalDate: $originalDate, createdDate: $createdDate, updatedDate: $updatedDate, md5String: $md5String, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin, collectionId: $collectionId, isAux: $isAux, isPreviewCached: $isPreviewCached, isMediaCached: $isMediaCached, previewLog: $previewLog, mediaLog: $mediaLog, isMediaOriginal: $isMediaOriginal, serverUID: $serverUID, isEdited: $isEdited, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.type == type &&
        other.fExt == fExt &&
        other.ref == ref &&
        other.originalDate == originalDate &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.md5String == md5String &&
        other.isDeleted == isDeleted &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        other.collectionId == collectionId &&
        other.isAux == isAux &&
        other.id == id &&
        other.isPreviewCached == isPreviewCached &&
        other.isMediaCached == isMediaCached &&
        other.previewLog == previewLog &&
        other.mediaLog == mediaLog &&
        other.isMediaOriginal == isMediaOriginal &&
        other.serverUID == serverUID &&
        other.isEdited == isEdited &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal;
  }

  @override
  bool isContentSame(covariant CLMedia other) {
    final isSame = other.name == name &&
        other.type == type &&
        other.fExt == fExt &&
        other.ref == ref &&
        other.originalDate == originalDate &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.md5String == md5String &&
        other.isDeleted == isDeleted &&
        other.collectionId == collectionId &&
        other.isAux == isAux &&
        other.serverUID == serverUID &&
        other.isEdited == isEdited &&
        other.haveItOffline == haveItOffline;
    if (!isSame) {
      // print(MapDiff.log(other.toMapForDisplay(), toMapForDisplay()));
    }
    return isSame;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        type.hashCode ^
        fExt.hashCode ^
        ref.hashCode ^
        originalDate.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        md5String.hashCode ^
        isDeleted.hashCode ^
        isHidden.hashCode ^
        pin.hashCode ^
        collectionId.hashCode ^
        isAux.hashCode ^
        id.hashCode ^
        isPreviewCached.hashCode ^
        isMediaCached.hashCode ^
        previewLog.hashCode ^
        mediaLog.hashCode ^
        isMediaOriginal.hashCode ^
        serverUID.hashCode ^
        isEdited.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode;
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'type': type.name,
      'fExt': fExt,
      'ref': ref,
      'originalDate': originalDate?.millisecondsSinceEpoch,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'md5String': md5String,
      'isDeleted': (isDeleted ?? false) ? 1 : 0,
      'isHidden': (isHidden ?? false) ? 1 : 0,
      'pin': pin,
      'collectionId': collectionId,
      'isAux': isAux ? 1 : 0,
      'id': id,
      'isPreviewCached': isPreviewCached ? 1 : 0,
      'isMediaCached': isMediaCached ? 1 : 0,
      'previewLog': previewLog,
      'mediaLog': mediaLog,
      'isMediaOriginal': isMediaOriginal ? 1 : 0,
      'serverUID': serverUID,
      'isEdited': isEdited == null ? null : (isEdited! ? 1 : 0),
      'haveItOffline': haveItOffline == null ? null : (haveItOffline! ? 1 : 0),
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
    };
  }

  Map<String, dynamic> toMapForDisplay() {
    return <String, dynamic>{
      'name': name,
      'type': type.name,
      'fExt': fExt,
      'ref': ref,
      'originalDate': originalDate,
      'createdDate': createdDate,
      'updatedDate': updatedDate,
      'md5String': md5String,
      'isDeleted': isDeleted,
      'isHidden': isDeleted,
      'pin': pin,
      'collectionId': collectionId,
      'isAux': isAux,
      'id': id,
      'isPreviewCached': isPreviewCached,
      'isMediaCached': isMediaCached,
      'previewLog': previewLog?.substring(0, min(15, previewLog?.length ?? 1)),
      'mediaLog': mediaLog?.substring(0, min(15, mediaLog?.length ?? 1)),
      'isMediaOriginal': isMediaOriginal,
      'serverUID': serverUID,
      'isEdited': isEdited,
      'haveItOffline': haveItOffline,
      'mustDownloadOriginal': mustDownloadOriginal,
    };
  }

  Map<String, String> toUploadMap() {
    final map = toMap();
    final serverFields = <String>[
      'name',
      'ref',
      'originalDate',
      'createdDate',
      'updatedDate',
      'isDeleted',
    ];
    map.removeWhere(
      (key, value) => !serverFields.contains(key) || value == null,
    );
    return map.map((key, value) => MapEntry(key, value.toString()));
  }

  @override
  String toJson() => json.encode(toMap());

  bool get isMediaDownloadFailed =>
      serverUID != null && !isMediaCached && mediaLog != null;

  bool get isMediaLocallyAvailable => serverUID == null || isMediaCached;

  bool get isPreviewWaitingForDownload =>
      serverUID != null && !isPreviewCached && previewLog == null;

  bool get isPreviewDownloadFailed => serverUID != null && previewLog != null;

  bool get isPreviewLocallyAvailable => serverUID == null || isPreviewCached;

  /// Modifying any of these parameters won't modify the date.
  CLMedia updateStatus({
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<bool>? isMediaCached,
    ValueGetter<bool>? isPreviewCached,
    ValueGetter<String?>? previewLog,
    ValueGetter<String?>? mediaLog,
    ValueGetter<bool>? isMediaOriginal,
    ValueGetter<bool?>? haveItOffline,
    ValueGetter<bool>? mustDownloadOriginal,
  }) {
    return _copyWith(
      isHidden: isHidden,
      pin: pin,
      isMediaCached: isMediaCached,
      isPreviewCached: isPreviewCached,
      previewLog: previewLog,
      mediaLog: mediaLog,
      isMediaOriginal: isMediaOriginal,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
    );
  }

  /// Modifying any of these parameter will be treated as content update
  /// and the updatedDate is automatically updated.
  /// if  createdDate is missing (is null), it will be updated with updatedDate
  ///
  CLMedia updateContent({
    required bool isEdited,
    ValueGetter<String>? name,
    ValueGetter<CLMediaType>? type,
    ValueGetter<String>? fExt,
    ValueGetter<String?>? ref,
    ValueGetter<DateTime?>? originalDate,
    ValueGetter<String?>? md5String,
    ValueGetter<bool?>? isDeleted,
    ValueGetter<int?>? collectionId,
    ValueGetter<bool>? isAux,
    ValueGetter<int?>? id,
    ValueGetter<int?>? serverUID,
  }) {
    final time = DateTime.now();
    return _copyWith(
      name: name,
      type: type,
      fExt: fExt,
      ref: ref,
      md5String: md5String,
      isDeleted: isDeleted,
      collectionId: collectionId,
      isAux: isAux,
      id: id,
      serverUID: serverUID,
      updatedDate: () => time,
      isEdited: () => isEdited,
    );
  }

  @override
  CLMedia copyWith({
    ValueGetter<String>? name,
    ValueGetter<CLMediaType>? type,
    ValueGetter<String>? fExt,
    ValueGetter<String?>? ref,
    ValueGetter<DateTime?>? originalDate,
    ValueGetter<DateTime?>? createdDate,
    ValueGetter<DateTime?>? updatedDate,
    ValueGetter<String?>? md5String,
    ValueGetter<bool?>? isDeleted,
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<int?>? collectionId,
    ValueGetter<bool>? isAux,
    ValueGetter<int?>? id,
    ValueGetter<bool>? isPreviewCached,
    ValueGetter<bool>? isMediaCached,
    ValueGetter<String?>? previewLog,
    ValueGetter<String?>? mediaLog,
    ValueGetter<bool>? isMediaOriginal,
    ValueGetter<int?>? serverUID,
    ValueGetter<bool>? isEdited,
    ValueGetter<bool>? haveItOffline,
    ValueGetter<bool>? mustDownloadOriginal,
  }) {
    throw Exception('use either updateContent or updateStatus');
  }

  @override
  bool isChangedAfter(CLEntity other) =>
      updatedDate.isAfter((other as CLMedia).updatedDate);

  @override
  bool get isMarkedDeleted => isDeleted ?? false;

  @override
  bool get isMarkedEditted => isEdited ?? false;

  @override
  bool get hasServerUID => serverUID != null;

  // for local item, always mark this flag, it will be filterred out
  // by collection. [caution]
  @override
  bool get isMarkedForUpload => serverUID == null;

  @override
  int? get entityId => id;

  @override
  DateTime? get entityOriginalDate => originalDate;
  @override
  DateTime get entityCreatedDate => createdDate;

  bool get isCached =>
      !hasServerUID || (hasServerUID && (isPreviewCached && isMediaCached));

  bool isMediaWaitingForDownload(Collection parentCollection) =>
      hasServerUID &&
      isMediaCached &&
      mediaLog == null &&
      switch (type) {
            CLMediaType.image => parentCollection.haveItOffline,
            _ => false
          } |
          (haveItOffline ?? false);

  bool get isMediaWaitingForDownloadINCORRECT =>
      !isMediaCached && mediaLog == null && (haveItOffline ?? false);
}
