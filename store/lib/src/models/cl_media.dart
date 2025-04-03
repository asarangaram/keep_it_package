import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_entities.dart';
import 'cl_media_base.dart';
import 'cl_media_type.dart';

@immutable
class CLMedia implements CLEntity {
  const CLMedia({
    required this.id,
    required this.label,
    required this.type,
    required this.extension,
    required this.parentId,
    required this.addedDate,
    required this.updatedDate,
    required this.description,
    required this.createDate,
    required this.md5,
    required this.isDeleted,
    this.isCollection = false,
    this.isHidden = false,
    this.isAux = false,
    this.pin,
  });
  const CLMedia.collection({
    required this.id,
    required this.label,
    required this.addedDate,
    required this.updatedDate,
    this.parentId,
    this.type,
    this.extension,
    this.description,
    this.createDate,
    this.md5,
    this.isDeleted = false,
    this.isCollection = true,
    this.isHidden = false,
    this.isAux = false,
    this.pin,
  });

  factory CLMedia.fromMap(Map<String, dynamic> map) {
    return CLMedia(
      id: map['id'] as int,
      isCollection: map['isCollection'] as int != 0,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      type: map['type'] as String?,
      extension: map['extension'] as String,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createDate'] as int)
          : null,
      addedDate: DateTime.fromMillisecondsSinceEpoch(map['addedDate'] as int),
      updatedDate:
          DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int),
      md5: map['md5'] != null ? map['md5'] as String : null,
      isDeleted: (map['isDeleted'] as int) != 0,
      isHidden: (map['isHidden'] as int? ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      isAux: (map['isAux'] as int? ?? 0) != 0,
    );
  }

  factory CLMedia.fromJson(String source) => CLMedia.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  final int? id;
  @override
  final bool isCollection;
  final DateTime addedDate;
  final DateTime updatedDate;
  final bool isDeleted;

  final String? label;
  final String? description;
  final int? parentId;

  final DateTime? createDate;
  final String? md5;
  final String? extension;
  final String? type;

  final bool isHidden;
  final String? pin;
  final bool isAux;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'type': type,
      'extension': extension,
      'description': description,
      'createDate': createDate?.millisecondsSinceEpoch,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'md5': md5,
      'isDeleted': isDeleted ? 1 : 0,
      'isHidden': isHidden ? 1 : 0,
      'pin': pin,
      'parentId': parentId,
      'isAux': isAux ? 1 : 0,
      'id': id,
    };
  }

  Map<String, dynamic> toMapForDisplay() {
    return <String, dynamic>{
      'label': label,
      'type': type,
      'extension': extension,
      'description': description,
      'createDate': createDate,
      'addedDate': addedDate,
      'updatedDate': updatedDate,
      'md5': md5,
      'isDeleted': isDeleted,
      'isHidden': isDeleted,
      'pin': pin,
      'parentId': parentId,
      'isAux': isAux,
      'id': id,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  int? get entityId => id;

  @override
  DateTime get sortDate => createDate ?? updatedDate;

  CLMedia copyWith({
    ValueGetter<int?>? id,
    bool? isCollection,
    DateTime? addedDate,
    DateTime? updatedDate,
    bool? isDeleted,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<DateTime?>? createDate,
    ValueGetter<String?>? md5,
    ValueGetter<String?>? extension,
    ValueGetter<String?>? type,
    bool? isHidden,
    ValueGetter<String?>? pin,
    bool? isAux,
  }) {
    return CLMedia(
      id: id != null ? id.call() : this.id,
      isCollection: isCollection ?? this.isCollection,
      addedDate: addedDate ?? this.addedDate,
      updatedDate: updatedDate ?? this.updatedDate,
      isDeleted: isDeleted ?? this.isDeleted,
      label: label != null ? label.call() : this.label,
      description: description != null ? description.call() : this.description,
      parentId: parentId != null ? parentId.call() : this.parentId,
      createDate: createDate != null ? createDate.call() : this.createDate,
      md5: md5 != null ? md5.call() : this.md5,
      extension: extension != null ? extension.call() : this.extension,
      type: type != null ? type.call() : this.type,
      isHidden: isHidden ?? this.isHidden,
      pin: pin != null ? pin.call() : this.pin,
      isAux: isAux ?? this.isAux,
    );
  }

  @override
  String toString() {
    return 'CLEntity(id: $id, isCollection: $isCollection, addedDate: $addedDate, updatedDate: $updatedDate, isDeleted: $isDeleted, label: $label, description: $description, parentId: $parentId, createDate: $createDate, md5: $md5, extension: $extension, type: $type, isHidden: $isHidden, pin: $pin, isAux: $isAux)';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.isCollection == isCollection &&
        other.addedDate == addedDate &&
        other.updatedDate == updatedDate &&
        other.isDeleted == isDeleted &&
        other.label == label &&
        other.description == description &&
        other.parentId == parentId &&
        other.createDate == createDate &&
        other.md5 == md5 &&
        other.extension == extension &&
        other.type == type &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        other.isAux == isAux;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isCollection.hashCode ^
        addedDate.hashCode ^
        updatedDate.hashCode ^
        isDeleted.hashCode ^
        label.hashCode ^
        description.hashCode ^
        parentId.hashCode ^
        createDate.hashCode ^
        md5.hashCode ^
        extension.hashCode ^
        type.hashCode ^
        isHidden.hashCode ^
        pin.hashCode ^
        isAux.hashCode;
  }

  /// Modifying any of these parameter will be treated as content update
  /// and the updatedDate is automatically updated.
  /// if  createdDate is missing (is null), it will be updated with updatedDate
  ///
  CLMedia updateContent({
    ValueGetter<String?>? label,
    ValueGetter<String?>? type,
    ValueGetter<String>? extension,
    ValueGetter<String?>? description,
    ValueGetter<DateTime?>? originalDate,
    ValueGetter<String?>? md5String,
    ValueGetter<bool?>? isDeleted,
    ValueGetter<int?>? collectionId,
    ValueGetter<bool>? isAux,
    ValueGetter<int?>? id,
  }) {
    final time = DateTime.now();
    return copyWith(
      label: label,
      type: type,
      extension: extension,
      description: description,
      md5: md5String,
      isDeleted: isDeleted?.call(),
      parentId: collectionId,
      isAux: isAux?.call(),
      id: id,
      updatedDate: time,
    );
  }

  CLMedia updateStatus({
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
  }) {
    return copyWith(
      isHidden: isHidden?.call(),
      pin: pin,
    );
  }

  CLMediaType get mediaType => CLMediaType.values.asNameMap()[type]!;
}
