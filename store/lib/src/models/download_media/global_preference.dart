// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class DownloadMediaGlobalPreference {
  const DownloadMediaGlobalPreference({
    required this.previewDimension,
    required this.downloadMediaDimension,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
  });

  factory DownloadMediaGlobalPreference.fromMap(Map<String, dynamic> map) {
    return DownloadMediaGlobalPreference(
      previewDimension: map['previewDimension'] as int,
      downloadMediaDimension: map['downloadMediaDimension'] as int,
      haveItOffline: (map['haveItOffline'] as int) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int) != 0,
    );
  }

  factory DownloadMediaGlobalPreference.fromJson(String source) =>
      DownloadMediaGlobalPreference.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  factory DownloadMediaGlobalPreference.preferred() {
    // change the best value for each platform based
    // on the screensize
    return const DownloadMediaGlobalPreference(
      previewDimension: 256,
      downloadMediaDimension: 720,
      haveItOffline: true,
      mustDownloadOriginal: false,
    );
  }

  final int previewDimension;
  final int downloadMediaDimension;
  final bool haveItOffline;
  final bool mustDownloadOriginal;

  DownloadMediaGlobalPreference copyWith({
    int? previewDimension,
    int? downloadMediaDimension,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
  }) {
    return DownloadMediaGlobalPreference(
      previewDimension: previewDimension ?? this.previewDimension,
      downloadMediaDimension:
          downloadMediaDimension ?? this.downloadMediaDimension,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'previewDimension': previewDimension,
      'downloadMediaDimension': downloadMediaDimension,
      'haveItOffline': haveItOffline ? 1 : 0,
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DownloadSettings(previewDimension: $previewDimension, downloadMediaDimension: $downloadMediaDimension, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal)';
  }

  @override
  bool operator ==(covariant DownloadMediaGlobalPreference other) {
    if (identical(this, other)) return true;

    return other.previewDimension == previewDimension &&
        other.downloadMediaDimension == downloadMediaDimension &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal;
  }

  @override
  int get hashCode {
    return previewDimension.hashCode ^
        downloadMediaDimension.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode;
  }
}
