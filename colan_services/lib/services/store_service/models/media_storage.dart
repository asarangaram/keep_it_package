// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MediaStorage {
  const MediaStorage({
    required this.previewPath,
    required this.mediaPath,
    required this.originalMediaPath,
  });
  final AsyncValue<Uri> previewPath;
  final AsyncValue<Uri> mediaPath;
  final AsyncValue<Uri> originalMediaPath;

  MediaStorage copyWith({
    AsyncValue<Uri>? previewPath,
    AsyncValue<Uri>? mediaPath,
    AsyncValue<Uri>? originalMediaPath,
  }) {
    return MediaStorage(
      previewPath: previewPath ?? this.previewPath,
      mediaPath: mediaPath ?? this.mediaPath,
      originalMediaPath: originalMediaPath ?? this.originalMediaPath,
    );
  }

  @override
  // ignore: lines_longer_than_80_chars
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'MediaStorage(previewPath: $previewPath, mediaPath: $mediaPath, originalMediaPath: $originalMediaPath)';

  @override
  bool operator ==(covariant MediaStorage other) {
    if (identical(this, other)) return true;

    return other.previewPath == previewPath &&
        other.mediaPath == mediaPath &&
        other.originalMediaPath == originalMediaPath;
  }

  @override
  int get hashCode =>
      previewPath.hashCode ^ mediaPath.hashCode ^ originalMediaPath.hashCode;

  factory MediaStorage.asyncLoading() {
    return const MediaStorage(
      previewPath: AsyncLoading(),
      mediaPath: AsyncLoading(),
      originalMediaPath: AsyncLoading(),
    );
  }
  factory MediaStorage.asyncError(Object e, StackTrace st) {
    return MediaStorage(
      previewPath: AsyncValue.error(e, st),
      mediaPath: AsyncValue.error(e, st),
      originalMediaPath: AsyncValue.error(e, st),
    );
  }
}
