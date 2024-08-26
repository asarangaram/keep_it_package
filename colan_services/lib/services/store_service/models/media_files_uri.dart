/* // ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class MediaFilesUri {
  const MediaFilesUri({
    required this.previewPath,
    required this.mediaPath,
    required this.originalMediaPath,
  });

  final Uri? previewPath;
  final Uri? mediaPath;
  final Uri? originalMediaPath;

  MediaFilesUri copyWith({
    Uri? previewPath,
    Uri? mediaPath,
    Uri? originalMediaPath,
  }) {
    return MediaFilesUri(
      previewPath: previewPath ?? this.previewPath,
      mediaPath: mediaPath ?? this.mediaPath,
      originalMediaPath: originalMediaPath ?? this.originalMediaPath,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'MediaFilesUri(previewPath: $previewPath, mediaPath:
       $mediaPath, originalMediaPath: $originalMediaPath)';

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
 */
