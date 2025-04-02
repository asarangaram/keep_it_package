import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_entities.dart';
import 'cl_media_base.dart';
import 'cl_media_type.dart';

@immutable
class CLMedia extends CLMediaBase implements CLEntity {
  const CLMedia._({
    required super.name,
    required super.type,
    required super.fExt,
    required super.collectionId,
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
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    final time = DateTime.now();
    return CLMedia._(
      name: name,
      type: type,
      fExt: fExt,
      collectionId: collectionId,
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
      fExt: map['fExt'] as String,
      ref: map['ref'] != null ? map['ref'] as String : null,
      originalDate: map['originalDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['originalDate'] as int)
          : null,
      createdDate:
          DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int),
      updatedDate:
          DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int),
      md5String: map['md5String'] != null ? map['md5String'] as String : null,
      isDeleted: (map['isDeleted'] as int) != 0,
      isHidden: (map['isHidden'] as int? ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      collectionId:
          map['collectionId'] != null ? map['collectionId'] as int : null,
      isAux: (map['isAux'] as int? ?? 0) != 0,
      id: map['id'] != null ? map['id'] as int : null,
    );
  }

  factory CLMedia.fromJson(String source) => CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  final int? id;
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
  }) {
    return CLMedia.strict(
      name: name != null ? name() : this.name,
      type: type != null ? type() : this.type,
      fExt: fExt != null ? fExt() : this.fExt,
      collectionId: collectionId != null ? collectionId() : this.collectionId,
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
    return 'CLMedia(id: $id, createdDate: $createdDate, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ createdDate.hashCode ^ updatedDate.hashCode;
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
    );
  }

  /// Modifying any of these parameter will be treated as content update
  /// and the updatedDate is automatically updated.
  /// if  createdDate is missing (is null), it will be updated with updatedDate
  ///
  CLMedia updateContent({
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
      updatedDate: () => time,
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
  bool get isMarkedDeleted => isDeleted ?? false;

  @override
  int? get entityId => id;

  @override
  DateTime? get entityOriginalDate => originalDate;
  @override
  DateTime get entityCreatedDate => createdDate;
}
