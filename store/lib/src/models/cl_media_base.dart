import 'dart:io';

import 'package:meta/meta.dart';

import '../extensions/ext_file.dart';
import 'cl_media_type.dart';

typedef ValueGetter<T> = T Function();

@immutable
class CLMediaBase {
  const CLMediaBase({
    required this.path,
    required this.type,
  });

  final String path;
  final CLMediaType type;

  Future<void> deleteFile() async {
    await File(path).deleteIfExists();
  }

  CLMediaBase copyWith({
    ValueGetter<String>? path,
    ValueGetter<CLMediaType>? type,
    ValueGetter<String?>? description,
    ValueGetter<DateTime?>? createDateDELETE,
    ValueGetter<String?>? md5,
    ValueGetter<bool?>? isDeletedDELETE,
    ValueGetter<bool?>? isHiddenDELETE,
    ValueGetter<String?>? pinDELETE,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isAuxDELETE,
  }) {
    return CLMediaBase(
      path: path != null ? path() : this.path,
      type: type != null ? type() : this.type,
    );
  }

  @override
  String toString() => 'CLMediaBase(path: $path, type: $type)';

  @override
  bool operator ==(covariant CLMediaBase other) {
    if (identical(this, other)) return true;

    return other.path == path && other.type == type;
  }

  @override
  int get hashCode => path.hashCode ^ type.hashCode;
}
