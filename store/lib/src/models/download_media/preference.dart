// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class DownloadMediaPreference {
  const DownloadMediaPreference({
    required this.haveItOffline,
    required this.mustDownloadOriginal,
  });
  final bool haveItOffline;
  final bool mustDownloadOriginal;

  DownloadMediaPreference copyWith({
    bool? haveItOffline,
    bool? mustDownloadOriginal,
  }) {
    return DownloadMediaPreference(
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'DownloadMediaPreference(haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal)';

  @override
  bool operator ==(covariant DownloadMediaPreference other) {
    if (identical(this, other)) return true;

    return other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal;
  }

  @override
  int get hashCode => haveItOffline.hashCode ^ mustDownloadOriginal.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'haveItOffline': haveItOffline ? 1 : 0,
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
    };
  }

  factory DownloadMediaPreference.fromMap(Map<String, dynamic> map) {
    return DownloadMediaPreference(
      haveItOffline: (map['haveItOffline'] as int) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int) != 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloadMediaPreference.fromJson(String source) =>
      DownloadMediaPreference.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
