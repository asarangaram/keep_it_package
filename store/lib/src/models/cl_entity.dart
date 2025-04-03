import 'dart:convert';

import 'package:meta/meta.dart';

import 'data_types.dart';
import 'viewer_entity_mixin.dart';

@immutable
class CLEntity implements ViewerEntityMixin {
  const CLEntity({
    required this.isCollection,
    required this.addedDate,
    required this.updatedDate,
    required this.isDeleted,
    required this.id,
    required this.label,
    required this.description,
    required this.parentId,
    required this.md5,
    required this.fileSize,
    required this.mimeType,
    required this.type,
    required this.extension,
    required this.createDate,
    required this.height,
    required this.width,
    required this.duration,
    required this.isHidden,
    required this.pin,
  });

  factory CLEntity.fromMap(Map<String, dynamic> map) {
    return CLEntity(
      id: map['id'] != null ? map['id'] as int : null,
      isCollection: (map['isCollection'] ?? false) as bool,
      addedDate:
          DateTime.fromMillisecondsSinceEpoch((map['addedDate'] ?? 0) as int),
      updatedDate:
          DateTime.fromMillisecondsSinceEpoch((map['updatedDate'] ?? 0) as int),
      isDeleted: (map['isDeleted'] ?? false) as bool,
      label: map['label'] != null ? map['label'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      md5: map['md5'] != null ? map['md5'] as String : null,
      fileSize: map['fileSize'] != null ? map['fileSize'] as int : null,
      mimeType: map['mimeType'] != null ? map['mimeType'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
      extension: map['extension'] != null ? map['extension'] as String : null,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createDate'] ?? 0) as int)
          : null,
      height: map['height'] != null ? map['height'] as int : null,
      width: map['width'] != null ? map['width'] as int : null,
      duration: map['duration'] != null ? map['duration'] as double : null,
      isHidden: (map['isHidden'] ?? false) as bool,
      pin: map['pin'] != null ? map['pin'] as String : null,
    );
  }

  factory CLEntity.fromJson(String source) =>
      CLEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  // Change to factory!
  factory CLEntity.collection({
    required String label,
    bool isDeleted = false,
    int? id,
    String? description,
    int? parentId,
  }) {
    final addedDate = DateTime.now();
    final updatedDate = addedDate;
    return CLEntity(
      isCollection: true,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      id: id,
      label: label,
      description: description,
      parentId: parentId,
      md5: null,
      fileSize: null,
      mimeType: null,
      type: null,
      extension: null,
      createDate: null,
      height: null,
      width: null,
      duration: null,
      isHidden: false,
      pin: null,
    );
  }

  factory CLEntity.media({
    required bool isDeleted,
    required String md5,
    required int fileSize,
    required String mimeType,
    required String type,
    required String extension,
    int? id,
    String? label,
    String? description,
    int? parentId,
    DateTime? createDate,
    int? height,
    int? width,
    double? duration,
    bool isHidden = false,
    String? pin,
  }) {
    final addedDate = DateTime.now();
    final updatedDate = addedDate;
    return CLEntity(
      isCollection: true,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      id: id,
      label: label,
      description: description,
      parentId: parentId,
      md5: md5,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      extension: extension,
      createDate: createDate,
      height: height,
      width: width,
      duration: duration,
      isHidden: isHidden,
      pin: pin,
    );
  }

  @override
  final int? id;
  @override
  final bool isCollection;
  final DateTime addedDate;
  final DateTime updatedDate;
  final bool isDeleted;

  final String? label;
  final String? description;
  final int? parentId;

  final String? md5;
  final int? fileSize;
  final String? mimeType;
  final String? type;
  final String? extension;

  final DateTime? createDate;
  final int? height;
  final int? width;
  final double? duration;

  final bool isHidden;
  final String? pin;

  CLEntity copyWith({
    ValueGetter<int?>? id,
    bool? isCollection,
    DateTime? addedDate,
    DateTime? updatedDate,
    bool? isDeleted,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<String?>? md5,
    ValueGetter<int?>? fileSize,
    ValueGetter<String?>? mimeType,
    ValueGetter<String?>? type,
    ValueGetter<String?>? extension,
    ValueGetter<DateTime?>? createDate,
    ValueGetter<int?>? height,
    ValueGetter<int?>? width,
    ValueGetter<double?>? duration,
    bool? isHidden,
    ValueGetter<String?>? pin,
  }) {
    return CLEntity(
      id: id != null ? id.call() : this.id,
      isCollection: isCollection ?? this.isCollection,
      addedDate: addedDate ?? this.addedDate,
      updatedDate: updatedDate ?? this.updatedDate,
      isDeleted: isDeleted ?? this.isDeleted,
      label: label != null ? label.call() : this.label,
      description: description != null ? description.call() : this.description,
      parentId: parentId != null ? parentId.call() : this.parentId,
      md5: md5 != null ? md5.call() : this.md5,
      fileSize: fileSize != null ? fileSize.call() : this.fileSize,
      mimeType: mimeType != null ? mimeType.call() : this.mimeType,
      type: type != null ? type.call() : this.type,
      extension: extension != null ? extension.call() : this.extension,
      createDate: createDate != null ? createDate.call() : this.createDate,
      height: height != null ? height.call() : this.height,
      width: width != null ? width.call() : this.width,
      duration: duration != null ? duration.call() : this.duration,
      isHidden: isHidden ?? this.isHidden,
      pin: pin != null ? pin.call() : this.pin,
    );
  }

  @override
  String toString() {
    return 'CLEntity(id: $id, isCollection: $isCollection, addedDate: $addedDate, updatedDate: $updatedDate, isDeleted: $isDeleted, label: $label, description: $description, parentId: $parentId, md5: $md5, fileSize: $fileSize, mimeType: $mimeType, type: $type, extension: $extension, createDate: $createDate, height: $height, width: $width, duration: $duration, isHidden: $isHidden, pin: $pin)';
  }

  @override
  bool operator ==(covariant CLEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.isCollection == isCollection &&
        other.addedDate == addedDate &&
        other.updatedDate == updatedDate &&
        other.isDeleted == isDeleted &&
        other.label == label &&
        other.description == description &&
        other.parentId == parentId &&
        other.md5 == md5 &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.type == type &&
        other.extension == extension &&
        other.createDate == createDate &&
        other.height == height &&
        other.width == width &&
        other.duration == duration &&
        other.isHidden == isHidden &&
        other.pin == pin;
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
        md5.hashCode ^
        fileSize.hashCode ^
        mimeType.hashCode ^
        type.hashCode ^
        extension.hashCode ^
        createDate.hashCode ^
        height.hashCode ^
        width.hashCode ^
        duration.hashCode ^
        isHidden.hashCode ^
        pin.hashCode;
  }

  @override
  DateTime get sortDate => createDate ?? updatedDate;

  CLMediaType get mediaType => CLMediaType.values.asNameMap()[type]!;

  CLEntity updateContent({
    bool? isDeleted,
    ValueGetter<String?>? label,
    ValueGetter<String?>? description,
    ValueGetter<int?>? parentId,
    ValueGetter<String?>? md5,
    ValueGetter<int?>? fileSize,
    ValueGetter<String?>? mimeType,
    ValueGetter<String?>? type,
    ValueGetter<String?>? extension,
    ValueGetter<DateTime?>? createDate,
    ValueGetter<int?>? height,
    ValueGetter<int?>? width,
    ValueGetter<double?>? duration,
  }) {
    if (md5 != null && pin != null) {
      throw Exception("Can't update content when its pinned");
    }
    if (md5 == null &&
        [
          fileSize,
          mimeType,
          type,
          extension,
          createDate,
          height,
          width,
          duration,
        ].any((e) => e != null)) {
      throw Exception(
        "file parameters can't be updated when the file is not changed",
      );
    }
    final updatedDate = DateTime.now();
    return CLEntity(
      id: id,
      isCollection: isCollection,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted ?? this.isDeleted,
      label: label != null ? label.call() : this.label,
      description: description != null ? description.call() : this.description,
      parentId: parentId != null ? parentId.call() : this.parentId,
      md5: md5 != null ? md5.call() : this.md5,
      fileSize: fileSize != null ? fileSize.call() : this.fileSize,
      mimeType: mimeType != null ? mimeType.call() : this.mimeType,
      type: type != null ? type.call() : this.type,
      extension: extension != null ? extension.call() : this.extension,
      createDate: createDate != null ? createDate.call() : this.createDate,
      height: height != null ? height.call() : this.height,
      width: width != null ? width.call() : this.width,
      duration: duration != null ? duration.call() : this.duration,
      isHidden: isHidden,
      pin: pin,
    );
  }

  CLEntity updateStatus({
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
  }) {
    return CLEntity(
      id: id,
      isCollection: isCollection,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      label: label,
      description: description,
      parentId: parentId,
      md5: md5,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      extension: extension,
      createDate: createDate,
      height: height,
      width: width,
      duration: duration,
      isHidden: isHidden != null ? isHidden() : this.isHidden,
      pin: pin != null ? pin() : this.pin,
    );
  }

  CLEntity clone({
    ValueGetter<int?>? id,
  }) {
    final addedDate = DateTime.now();
    final updatedDate = addedDate;
    return CLEntity(
      id: id != null ? id() : this.id,
      isCollection: isCollection,
      addedDate: addedDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      label: label,
      description: description,
      parentId: parentId,
      md5: md5,
      fileSize: fileSize,
      mimeType: mimeType,
      type: type,
      extension: extension,
      createDate: createDate,
      height: height,
      width: width,
      duration: duration,
      isHidden: isHidden,
      pin: pin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isCollection': isCollection,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'label': label,
      'description': description,
      'parentId': parentId,
      'md5': md5,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type,
      'extension': extension,
      'createDate': createDate?.millisecondsSinceEpoch,
      'height': height,
      'width': width,
      'duration': duration,
      'isHidden': isHidden,
      'pin': pin,
    };
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMapForDisplay() {
    return <String, dynamic>{
      'id': id,
      'isCollection': isCollection,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'updatedDate': updatedDate.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'label': label,
      'description': description,
      'parentId': parentId,
      'md5': md5,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'type': type,
      'extension': extension,
      'createDate': createDate?.millisecondsSinceEpoch,
      'height': height,
      'width': width,
      'duration': duration,
      'isHidden': isHidden,
      'pin': pin,
    }..removeWhere((key, value) => value == null);
  }
}
