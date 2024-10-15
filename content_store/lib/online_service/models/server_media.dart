import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

@immutable
class ServerUploadEntity {
  factory ServerUploadEntity({
    required String path,
    required String name,
    required String collectionLabel,
    required DateTime createdDate,
    required DateTime updatedDate,
    required bool isDeleted,
    DateTime? originalDate,
    String? ref,
    List<int>? notes,
    int? serverUID,
  }) {
    return ServerUploadEntity._(
      path: path,
      name: name,
      collectionLabel: collectionLabel,
      createdDate: createdDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      originalDate: originalDate,
      ref: ref,
      notes: notes,
      serverUID: serverUID,
    );
  }
  factory ServerUploadEntity.fromCLMedia(
    CLMedia? media, {
    String? path,
    String? collectionLabel,
    List<int>? notes,
  }) {
    return ServerUploadEntity._(
      path: path,
      name: media?.name,
      collectionLabel: collectionLabel,
      createdDate: media?.createdDate,
      updatedDate: media?.updatedDate,
      isDeleted: media?.isDeleted,
      originalDate: media?.originalDate,
      ref: media?.ref,
      notes: notes,
      serverUID: media?.serverUID,
    );
  }
  factory ServerUploadEntity.update({
    required int serverUID,
    String? path,
    String? name,
    String? collectionLabel,
    DateTime? createdDate,
    DateTime? updatedDate,
    bool? isDeleted,
    DateTime? originalDate,
    String? ref,
    List<int>? notes,
  }) {
    return ServerUploadEntity._(
      path: path,
      name: name,
      collectionLabel: collectionLabel,
      createdDate: createdDate,
      updatedDate: updatedDate,
      isDeleted: isDeleted,
      originalDate: originalDate,
      ref: ref,
      notes: notes,
      serverUID: serverUID,
    );
  }
  ServerUploadEntity._({
    this.path,
    this.name,
    this.collectionLabel,
    this.createdDate,
    this.updatedDate,
    this.isDeleted,
    this.originalDate,
    this.ref,
    this.notes,
    this.serverUID,
  }) {
    if (serverUID == null && !isComplete) {
      throw Exception('new media must contain all required fields.');
    }
  }
  final String? path;
  final String? name;
  final String? collectionLabel;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final bool? isDeleted;
  final DateTime? originalDate;
  final String? ref;
  final List<int>? notes;
  final int? serverUID;

  Map<String, String> get fields {
    return {
      if (name != null) 'name': name!,
      if (collectionLabel != null) 'collectionLabel': collectionLabel!,
      if (createdDate != null)
        'createdDate': createdDate!.millisecondsSinceEpoch.toString(),
      if (updatedDate != null)
        'updatedDate': updatedDate!.millisecondsSinceEpoch.toString(),
      if (isDeleted != null) 'isDeleted': isDeleted! ? '1' : '0',
      if (originalDate != null)
        'originalDate': originalDate!.millisecondsSinceEpoch.toString(),
      if (ref != null) 'ref': ref!,
      if (notes != null) 'notes': '[${notes!.join(', ')}]',
    };
  }

  bool get isComplete {
    return [
      path,
      name,
      collectionLabel,
      createdDate,
      updatedDate,
      isDeleted,
    ].every((e) => e != null);
  }

  bool get hasFile => path != null;

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ServerMedia(path: $path, name: $name, collectionLabel: $collectionLabel, createdDate: $createdDate, updatedDate: $updatedDate, isDeleted: $isDeleted, originalDate: $originalDate, ref: $ref, notes: $notes, serverUID: $serverUID)';
  }

  @override
  bool operator ==(covariant ServerUploadEntity other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.path == path &&
        other.name == name &&
        other.collectionLabel == collectionLabel &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.isDeleted == isDeleted &&
        other.originalDate == originalDate &&
        other.ref == ref &&
        listEquals(other.notes, notes) &&
        other.serverUID == serverUID;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        name.hashCode ^
        collectionLabel.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        isDeleted.hashCode ^
        originalDate.hashCode ^
        ref.hashCode ^
        notes.hashCode ^
        serverUID.hashCode;
  }
}
