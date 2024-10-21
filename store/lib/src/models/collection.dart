// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_media_base.dart';

enum CollectionStoragePreference {
  notSynced,

  syncing,
  synced;

  bool get isSynced => this == synced;
  bool get isSyncing => this == syncing;
  bool get isOnlineOnly => this == notSynced;
  bool get isOfflineOnly => this == notSynced;
}

@immutable
class Collection {
  const Collection({
    required this.label,
    required this.collectionStoragePreference,
    this.id,
    this.description,
    this.createdDate,
    this.updatedDate,
    this.serverUID,
  });
  final String label;
  final String? description;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final int? id;
  final CollectionStoragePreference collectionStoragePreference;
  final int? serverUID;

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] != null ? map['id'] as int : null,
      label: map['label'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int)
          : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedDate'] as int)
          : null,
      collectionStoragePreference: CollectionStoragePreference.values
          .asNameMap()[map['CollectionStoragePreference'] as String]!,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
    );
  }

  factory Collection.fromJson(String source) =>
      Collection.fromMap(json.decode(source) as Map<String, dynamic>);

  Collection copyWith({
    ValueGetter<int?>? id,
    String? label,
    ValueGetter<String?>? description,
    ValueGetter<DateTime?>? createdDate,
    ValueGetter<DateTime?>? updatedDate,
    CollectionStoragePreference? collectionStoragePreference,
    ValueGetter<int?>? serverUID,
  }) {
    return Collection(
      id: id != null ? id.call() : this.id,
      label: label ?? this.label,
      description: description != null ? description.call() : this.description,
      createdDate: createdDate != null ? createdDate.call() : this.createdDate,
      updatedDate: updatedDate != null ? updatedDate.call() : this.updatedDate,
      collectionStoragePreference:
          collectionStoragePreference ?? this.collectionStoragePreference,
      serverUID: serverUID != null ? serverUID.call() : this.serverUID,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Collection(id: $id, label: $label, description: $description, createdDate: $createdDate, updatedDate: $updatedDate, collectionStoragePreference: $collectionStoragePreference, serverUID: $serverUID)';
  }

  @override
  bool operator ==(covariant Collection other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.label == label &&
        other.description == description &&
        other.createdDate == createdDate &&
        other.updatedDate == updatedDate &&
        other.collectionStoragePreference == collectionStoragePreference &&
        other.serverUID == serverUID;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        description.hashCode ^
        createdDate.hashCode ^
        updatedDate.hashCode ^
        collectionStoragePreference.hashCode ^
        serverUID.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'description': description,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
      'collectionStoragePreference': collectionStoragePreference.name,
      'serverUID': serverUID,
    };
  }

  String toJson() => json.encode(toMap());
}
