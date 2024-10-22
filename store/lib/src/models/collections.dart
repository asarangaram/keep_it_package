// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'collection.dart';

List<T> updateEntry<T>(
  List<T> list,
  bool Function(T) test,
  T Function(T) replaceBy,
) {
  final index = list.indexWhere(test);
  if (index == -1) {
    return list;
  }

  final updatedList = List<T>.from(list);

  updatedList[index] = replaceBy(updatedList[index]);

  return updatedList;
}

@immutable
class Collections {
  const Collections(
    this.entries,
  );
  final List<Collection> entries;

  Collections copyWith({
    List<Collection>? entries,
  }) {
    return Collections(
      entries ?? this.entries,
    );
  }

  @override
  String toString() => 'Collections(entries: $entries)';

  @override
  bool operator ==(covariant Collections other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entries, entries);
  }

  @override
  int get hashCode => entries.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'entries': entries.map((x) => x.toMap()).toList(),
    };
  }

  List<dynamic> toList() {
    return entries.map((x) => x.toMap()).toList();
  }

  factory Collections.fromMap(Map<String, dynamic> map) {
    return Collections(
      List<Collection>.from(
        (map['entries'] as List<int>).map<Collection>(
          (x) => Collection.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
  factory Collections.fromList(List<dynamic> map) {
    return Collections(
      List<Collection>.from(
        map.map<Collection>(
          (x) => Collection.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  String toJsonList() => json.encode(toList());

  factory Collections.fromJson(String source) =>
      Collections.fromList(json.decode(source) as List<dynamic>);

  Collections markForSyncing(int collectionID, {required int serverUID}) {
    final collection = entries.where((e) => e.id == collectionID).firstOrNull;
    if (collection == null) return this;
    if (collection.serverUID != null && collection.serverUID != serverUID) {
      throw Exception('Incorrect usage of serverUID');
    }

    return copyWith(
      entries: updateEntry(
        entries,
        (e) => e.id == collectionID,
        (collection) => collection.copyWith(
          serverUID: () => serverUID,
          collectionStoragePreference: CollectionStoragePreference.syncing,
        ),
      ),
    );
  }

  Collections revertSyncing(int collectionID) {
    throw UnimplementedError();
    /* final collection = entries.where(
    (e) => e.id == collectionID).firstOrNull;
    if (collection == null) return this;
    if (collection.collectionStoragePreference.isSynced ||
        collection.collectionStoragePreference.isSyncing) {
      // nothing to do
      return this;
    }
    return copyWith(
      entries: updateEntry(
        entries,
        (e) => e.id == collectionID,
        (collection) => collection.copyWith(
          collectionStoragePreference: CollectionStoragePreference.notSynced,
        ),
      ),
    ); */
  }

  // Can be moved only when the collection is syncing
  Collections markAsSynced(int collectionID) {
    final collection = entries.where((e) => e.id == collectionID).firstOrNull;
    if (collection == null) return this;
    if (!collection.collectionStoragePreference.isSyncing) {
      // nothing to do
      return this;
    }
    return copyWith(
      entries: updateEntry(
        entries,
        (e) => e.id == collectionID,
        (collection) => collection.copyWith(
          collectionStoragePreference: CollectionStoragePreference.synced,
        ),
      ),
    );
  }

  Collections removeServerCopy(int collectionID) {
    final collection = entries.where((e) => e.id == collectionID).firstOrNull;
    if (collection == null) return this;
    if (collection.serverUID == null) {
      // This is not a server collection, nothing to remove
      return this;
    }
    if (!collection.collectionStoragePreference.isSyncing) {
      // nothing to do
      return this;
    }
    return copyWith(
      entries: updateEntry(
        entries,
        (e) => e.id == collectionID,
        (collection) => collection.copyWith(
          collectionStoragePreference: CollectionStoragePreference.notSynced,
          serverUID: () => null, // we simply detach
        ),
      ),
    );
  }

  Collections removeLocalCopy(int collectionID) {
    final collection = entries.where((e) => e.id == collectionID).firstOrNull;
    if (collection == null) return this;

    if (collection.serverUID == null) {
      // This is not a server collection, nothing to remove
      return this;
    }
    if (!collection.collectionStoragePreference.isSyncing) {
      // nothing to do
      return this;
    }
    return copyWith(
      entries: updateEntry(
        entries,
        (e) => e.id == collectionID,
        (collection) => collection.copyWith(
          collectionStoragePreference: CollectionStoragePreference.notSynced,
        ),
      ),
    );
  }
}
