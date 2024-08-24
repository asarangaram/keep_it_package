import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MediaFilesUri {
  const MediaFilesUri({
    required this.previewPath,
    required this.mediaPath,
    required this.originalMediaPath,
  });

  factory MediaFilesUri.asyncLoading() {
    return const MediaFilesUri(
      previewPath: AsyncLoading<Uri>(),
      mediaPath: AsyncLoading<Uri>(),
      originalMediaPath: AsyncLoading<Uri>(),
    );
  }
  factory MediaFilesUri.asyncError(Object e, StackTrace st) {
    return MediaFilesUri(
      previewPath: AsyncValue.error(e, st),
      mediaPath: AsyncValue.error(e, st),
      originalMediaPath: AsyncValue.error(e, st),
    );
  }
  final AsyncValue<Uri> previewPath;
  final AsyncValue<Uri> mediaPath;
  final AsyncValue<Uri> originalMediaPath;

  MediaFilesUri copyWith({
    AsyncValue<Uri>? previewPath,
    AsyncValue<Uri>? mediaPath,
    AsyncValue<Uri>? originalMediaPath,
  }) {
    return MediaFilesUri(
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
  bool operator ==(covariant MediaFilesUri other) {
    if (identical(this, other)) return true;

    return other.previewPath == previewPath &&
        other.mediaPath == mediaPath &&
        other.originalMediaPath == originalMediaPath;
  }

  @override
  int get hashCode =>
      previewPath.hashCode ^ mediaPath.hashCode ^ originalMediaPath.hashCode;
}
