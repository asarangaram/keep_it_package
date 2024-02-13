// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class ThumbnailServiceDataIn {
  final int uuid;
  final String path;
  final String thumbnailPath;
  final bool isVideo;
  final int dimension;
  const ThumbnailServiceDataIn({
    required this.uuid,
    required this.path,
    required this.thumbnailPath,
    required this.isVideo,
    required this.dimension,
  });

  ThumbnailServiceDataIn copyWith({
    int? uuid,
    String? inPath,
    String? outPath,
    bool? isVideo,
    int? dimension,
  }) {
    return ThumbnailServiceDataIn(
      uuid: uuid ?? this.uuid,
      path: inPath ?? path,
      thumbnailPath: outPath ?? thumbnailPath,
      isVideo: isVideo ?? this.isVideo,
      dimension: dimension ?? this.dimension,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'inPath': path,
      'outPath': thumbnailPath,
      'isVideo': isVideo,
      'dimension': dimension,
    };
  }

  factory ThumbnailServiceDataIn.fromMap(Map<String, dynamic> map) {
    return ThumbnailServiceDataIn(
      uuid: map['uuid'] as int,
      path: map['inPath'] as String,
      thumbnailPath: map['outPath'] as String,
      isVideo: map['isVideo'] as bool,
      dimension: map['dimension'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ThumbnailServiceDataIn.fromJson(String source) =>
      ThumbnailServiceDataIn.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'ThumbnailServiceDataIn(uuid: $uuid, inPath: $path, outPath: $thumbnailPath, isVideo: $isVideo, dimension: $dimension)';
  }

  @override
  bool operator ==(covariant ThumbnailServiceDataIn other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.path == path &&
        other.thumbnailPath == thumbnailPath &&
        other.isVideo == isVideo &&
        other.dimension == dimension;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        path.hashCode ^
        thumbnailPath.hashCode ^
        isVideo.hashCode ^
        dimension.hashCode;
  }
}

@immutable
class ThumbnailServiceDataOut {
  final int uuid;

  final String? errorMsg;
  const ThumbnailServiceDataOut({
    required this.uuid,
    this.errorMsg,
  });

  ThumbnailServiceDataOut copyWith({
    int? uuid,
    String? errorMsg,
  }) {
    return ThumbnailServiceDataOut(
      uuid: uuid ?? this.uuid,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'errorMsg': errorMsg,
    };
  }

  factory ThumbnailServiceDataOut.fromMap(Map<String, dynamic> map) {
    return ThumbnailServiceDataOut(
      uuid: map['uuid'] as int,
      errorMsg: map['errorMsg'] != null ? map['errorMsg'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ThumbnailServiceDataOut.fromJson(String source) =>
      ThumbnailServiceDataOut.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() =>
      'ThumbnailServiceDataOut(uuid: $uuid, errorMsg: $errorMsg)';

  @override
  bool operator ==(covariant ThumbnailServiceDataOut other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid && other.errorMsg == errorMsg;
  }

  @override
  int get hashCode => uuid.hashCode ^ errorMsg.hashCode;
}
