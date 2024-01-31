import 'dart:io';
import 'package:flutter/material.dart';
import '../../extensions/ext_string.dart';

import '../file_handler.dart';
import 'cl_media_type.dart';

@immutable
class CLMedia {
  CLMedia({
    required this.path,
    required this.type,
    this.ref,
    //this.previewPath,
  }) {
    if (!path.startsWith('/')) {
      path.printString();
      throw Exception('CLMedia must have absolute path');
    }
  }
  final String path;
  final CLMediaType type;
  final String? ref;
  final previewWidth = 600;

  //final String? previewPath;

  CLMedia copyWith({
    String? path,
    String? ref,
    // String? previewPath,
  }) {
    return CLMedia(
      path: path ?? this.path,
      type: type,
      ref: ref ?? this.ref,
      // previewPath: previewPath ?? this.previewPath,
    );
  }

  Future<CLMedia> withPreview({
    bool forceCreate = false,
  }) async {
    return this;
  }

  void delete() {
    for (final f in [path /* , previewPath */]) {
      if (File(f).existsSync()) {
        File(f).deleteSync();
      }
    }
  }

  Future<String> get relativePathFuture async => FileHandler.relativePath(path);

  Future<CLMedia> move({required String toDir}) async {
    // final String? newPreviewPath;
    final String newPath;
    if (File(previewFileName).existsSync()) {
      await FileHandler.move(previewFileName, toSubFolder: toDir);
    }

    if (File(path).existsSync()) {
      newPath = await FileHandler.move(path, toSubFolder: toDir);
    } else {
      newPath = path;
    }
    return copyWith(
      path: newPath, /*  previewPath: newPreviewPath */
    );
  }

  Future<CLMedia> copy({required String toDir}) async {
    final String newPath;
    if (File(previewFileName).existsSync()) {
      await FileHandler.copy(previewFileName, toSubFolder: toDir);
    }

    if (File(path).existsSync()) {
      newPath = await FileHandler.copy(path, toSubFolder: toDir);
    } else {
      newPath = path;
    }
    return copyWith(path: newPath /* , previewPath: newPreviewPath */);
  }

  String get previewFileName => /* previewPath ??  */ '$path.jpg';

  @override
  String toString() {
    return 'CLMedia(path: $path, type: $type ';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.path == path &&
            other.type == type /* &&
        other.previewPath == previewPath */
        ;
  }

  @override
  int get hashCode {
    return path.hashCode ^ type.hashCode /* ^ previewPath.hashCode */;
  }

  bool get hasPreview => File(previewFileName).existsSync();
}

class CLMediaInfoGroup {
  CLMediaInfoGroup(this.list, {this.targetID});
  final List<CLMedia> list;
  final int? targetID;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => 'CLMediaInfoGroup(list: $list)';
}

extension EXTCLMediaInfoGroupNullable on CLMediaInfoGroup? {
  List<CLMediaInfoGroup> toList() {
    if (this == null) {
      return [];
    } else {
      return [this!];
    }
  }
}
