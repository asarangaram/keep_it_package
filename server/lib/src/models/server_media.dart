import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:store_revised/store_revised.dart';

@immutable
class Pagination {
  const Pagination({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
  });
  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;

  Pagination copyWith({
    int? currentPage,
    int? perPage,
    int? totalItems,
    int? totalPages,
  }) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentPage': currentPage,
      'perPage': perPage,
      'totalItems': totalItems,
      'totalPages': totalPages,
    };
  }

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      currentPage: map['currentPage'] as int,
      perPage: map['perPage'] as int,
      totalItems: map['totalItems'] as int,
      totalPages: map['totalPages'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Pagination.fromJson(String source) =>
      Pagination.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Pagination(currentPage: $currentPage, perPage: $perPage, totalItems: $totalItems, totalPages: $totalPages)';
  }

  @override
  bool operator ==(covariant Pagination other) {
    if (identical(this, other)) return true;

    return other.currentPage == currentPage &&
        other.perPage == perPage &&
        other.totalItems == totalItems &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode {
    return currentPage.hashCode ^
        perPage.hashCode ^
        totalItems.hashCode ^
        totalPages.hashCode;
  }

  bool get hasNext => currentPage < totalPages;
}

@immutable
class MetaInfo {
  const MetaInfo({
    required this.currentVersion,
    required this.lastSyncedVersion,
    required this.latestVersion,
    required this.pagination,
  });
  final int currentVersion;
  final int lastSyncedVersion;
  final int latestVersion;
  final Pagination pagination;

  MetaInfo copyWith({
    int? currentVersion,
    int? lastSyncedVersion,
    int? latestVersion,
    Pagination? pagination,
  }) {
    return MetaInfo(
      currentVersion: currentVersion ?? this.currentVersion,
      lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      pagination: pagination ?? this.pagination,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentVersion': currentVersion,
      'lastSyncedVersion': lastSyncedVersion,
      'latestVersion': latestVersion,
      'pagination': pagination.toMap(),
    };
  }

  factory MetaInfo.fromMap(Map<String, dynamic> map) {
    return MetaInfo(
      currentVersion: map['currentVersion'] as int,
      lastSyncedVersion: map['lastSyncedVersion'] as int,
      latestVersion: map['latestVersion'] as int,
      pagination: Pagination.fromMap(map['pagination'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory MetaInfo.fromJson(String source) =>
      MetaInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MetaInfo(currentVersion: $currentVersion, lastSyncedVersion: $lastSyncedVersion, latestVersion: $latestVersion, pagination: $pagination)';
  }

  @override
  bool operator ==(covariant MetaInfo other) {
    if (identical(this, other)) return true;

    return other.currentVersion == currentVersion &&
        other.lastSyncedVersion == lastSyncedVersion &&
        other.latestVersion == latestVersion &&
        other.pagination == pagination;
  }

  @override
  int get hashCode {
    return currentVersion.hashCode ^
        lastSyncedVersion.hashCode ^
        latestVersion.hashCode ^
        pagination.hashCode;
  }
}

@immutable
class ServerMedia {
  const ServerMedia({
    required this.items,
    required this.metaInfo,
    this.isLoading = false,
  });

  factory ServerMedia.reset(int perPage) {
    return ServerMedia(
        items: [],
        metaInfo: MetaInfo(
            currentVersion: 0,
            lastSyncedVersion: 0,
            latestVersion: 0,
            pagination: Pagination(
                currentPage: 0,
                perPage: perPage,
                totalItems: 0,
                totalPages: 0)));
  }
  final List<CLMedia> items;
  final MetaInfo metaInfo;
  final bool isLoading;

  ServerMedia copyWith({
    List<CLMedia>? items,
    MetaInfo? metaInfo,
    bool? isLoading,
  }) {
    return ServerMedia(
      items: items ?? this.items,
      metaInfo: metaInfo ?? this.metaInfo,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items.map((x) => x.toMap()).toList(),
      'metaInfo': metaInfo.toMap(),
    };
  }

  factory ServerMedia.fromMap(Map<String, dynamic> map) {
    return ServerMedia(
      items: List<CLMedia>.from(
        map['items'].map<CLMedia>(
          (x) {
            return CLMedia.fromMap(x as Map<String, dynamic>);
          },
        ),
      ),
      metaInfo: MetaInfo.fromMap(map['metaInfo'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerMedia.fromJson(String source) =>
      ServerMedia.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ServerMedia(items: $items, metaInfo: $metaInfo, isLoading: $isLoading)';

  @override
  bool operator ==(covariant ServerMedia other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) &&
        other.metaInfo == metaInfo &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => items.hashCode ^ metaInfo.hashCode ^ isLoading.hashCode;
}
