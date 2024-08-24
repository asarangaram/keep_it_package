import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class DownloadSettings {
  const DownloadSettings({
    required this.previewDimension,
    required this.downloadMediaDimension,
  });

  factory DownloadSettings.fromMap(Map<String, dynamic> map) {
    return DownloadSettings(
      previewDimension: map['previewDimension'] as int,
      downloadMediaDimension: map['downloadMediaDimension'] as int,
    );
  }

  factory DownloadSettings.fromJson(String source) =>
      DownloadSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  factory DownloadSettings.preferred() {
    // change the best value for each platform based
    // on the screensize
    return const DownloadSettings(
      previewDimension: 256,
      downloadMediaDimension: 720,
    );
  }

  final int previewDimension;
  final int downloadMediaDimension;

  DownloadSettings copyWith({
    int? previewDimension,
    int? downloadMediaDimension,
  }) {
    return DownloadSettings(
      previewDimension: previewDimension ?? this.previewDimension,
      downloadMediaDimension:
          downloadMediaDimension ?? this.downloadMediaDimension,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'previewDimension': previewDimension,
      'downloadMediaDimension': downloadMediaDimension,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'DownloadSettings(previewDimension: $previewDimension, downloadMediaDimension: $downloadMediaDimension)';

  @override
  bool operator ==(covariant DownloadSettings other) {
    if (identical(this, other)) return true;

    return other.previewDimension == previewDimension &&
        other.downloadMediaDimension == downloadMediaDimension;
  }

  @override
  int get hashCode =>
      previewDimension.hashCode ^ downloadMediaDimension.hashCode;
}
