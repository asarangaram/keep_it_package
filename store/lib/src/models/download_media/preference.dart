// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class MediaPreference {
  const MediaPreference({
    required this.id,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
  });
  final int id;
  final bool haveItOffline;
  final bool mustDownloadOriginal;

  MediaPreference copyWith({
    int? id,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
  }) {
    return MediaPreference(
      id: id ?? this.id,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'MediaPreference(id: $id, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal)';

  @override
  bool operator ==(covariant MediaPreference other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal;
  }

  @override
  int get hashCode =>
      id.hashCode ^ haveItOffline.hashCode ^ mustDownloadOriginal.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'haveItOffline': haveItOffline ? 1 : 0,
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
    };
  }

  factory MediaPreference.fromMap(Map<String, dynamic> map) {
    return MediaPreference(
      id: map['id'] as int,
      haveItOffline: (map['haveItOffline'] as int) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int) != 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaPreference.fromJson(String source) => MediaPreference.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
