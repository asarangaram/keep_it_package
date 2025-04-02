import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import '../extensions/ext_file.dart';
import 'cl_media_type.dart';

typedef ValueGetter<T> = T Function();

@immutable
class CLMediaBase {
  const CLMediaBase({
    required this.label,
    required this.type,
    required this.extension,
    this.description,
    this.createDate,
    this.md5,
    this.isDeleted,
    this.isHidden,
    this.pin,
    this.parentId,
    this.isAux = false,
  });

  factory CLMediaBase.fromMap(Map<String, dynamic> map) {
    return CLMediaBase(
      label: map['name'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
      extension: map['extension'] as String,
      description: map['description'] != null ? map['ref'] as String : null,
      createDate: map['createDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createDate'] as int)
          : null,
      md5: map['md5'] != null ? map['md5'] as String : null,
      isDeleted: (map['isDeleted'] as int) != 0,
      isHidden: (map['isHidden'] as int? ?? 0) != 0,
      pin: map['pin'] != null ? map['pin'] as String : null,
      parentId: map['parentId'] != null ? map['parentId'] as int : null,
      isAux: (map['isAux'] as int? ?? 0) != 0,
    );
  }

  factory CLMediaBase.fromJson(String source) =>
      CLMediaBase.fromMap(json.decode(source) as Map<String, dynamic>);

  final String label;
  final CLMediaType type;
  final String extension;
  final String? description;
  final DateTime? createDate;

  final String? md5;
  final bool? isDeleted;
  final bool? isHidden;
  final String? pin;
  final int? parentId;
  final bool isAux;

  Future<void> deleteFile() async {
    await File(label).deleteIfExists();
  }

  CLMediaBase copyWith({
    ValueGetter<String>? label,
    ValueGetter<CLMediaType>? type,
    ValueGetter<String>? extension,
    ValueGetter<String?>? description,
    ValueGetter<DateTime?>? createDate,
    ValueGetter<String?>? md5,
    ValueGetter<bool?>? isDeleted,
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isAux,
  }) {
    return CLMediaBase(
      label: label != null ? label() : this.label,
      type: type != null ? type() : this.type,
      extension: extension != null ? extension() : this.extension,
      parentId: parentId != null ? parentId() : this.parentId,
      description: description != null ? description() : this.description,
      createDate: createDate != null ? createDate() : this.createDate,
      md5: md5 != null ? md5() : this.md5,
      isDeleted: isDeleted != null ? isDeleted() : this.isDeleted,
      isHidden: isHidden != null ? isHidden() : this.isHidden,
      pin: pin != null ? pin() : this.pin,
      isAux: isAux != null ? isAux() : this.isAux,
    );
  }

  @override
  String toString() {
    return 'CLMediaBase(name: $label, type: $type, fExt: $extension, ref: $description, originalDate: $createDate, md5String: $md5, isDeleted: $isDeleted, isHidden: $isHidden, pin: $pin, collectionId: $parentId, isAux: $isAux)';
  }

  @override
  bool operator ==(covariant CLMediaBase other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.type == type &&
        other.extension == extension &&
        other.description == description &&
        other.createDate == createDate &&
        other.md5 == md5 &&
        other.isDeleted == isDeleted &&
        other.isHidden == isHidden &&
        other.pin == pin &&
        other.parentId == parentId &&
        other.isAux == isAux;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        type.hashCode ^
        extension.hashCode ^
        description.hashCode ^
        createDate.hashCode ^
        md5.hashCode ^
        isDeleted.hashCode ^
        isHidden.hashCode ^
        pin.hashCode ^
        parentId.hashCode ^
        isAux.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'type': type.name,
      'extension': extension,
      'description': description,
      'createDate': createDate?.millisecondsSinceEpoch,
      'md5': md5,
      'isDeleted': (isDeleted ?? false) ? 1 : 0,
      'isHidden': (isHidden ?? false) ? 1 : 0,
      'pin': pin,
      'parentId': parentId,
      'isAux': isAux,
    };
  }

  String toJson() => json.encode(toMap());
}
