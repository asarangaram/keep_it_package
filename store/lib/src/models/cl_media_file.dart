// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'cl_media_type.dart';

@immutable
class CLMediaFile {
  const CLMediaFile({
    required this.path,
    required this.type,
  });
  final String path;
  final CLMediaType type;

  CLMediaFile copyWith({
    String? path,
    CLMediaType? type,
  }) {
    return CLMediaFile(
      path: path ?? this.path,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => 'CLMediaFile(path: $path, type: $type)';

  @override
  bool operator ==(covariant CLMediaFile other) {
    if (identical(this, other)) return true;

    return other.path == path && other.type == type;
  }

  @override
  int get hashCode => path.hashCode ^ type.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'type': type.name,
    };
  }

  factory CLMediaFile.fromMap(Map<String, dynamic> map) {
    return CLMediaFile(
      path: map['path'] as String,
      type: CLMediaType.values.asNameMap()[map['type'] as String]!,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLMediaFile.fromJson(String source) =>
      CLMediaFile.fromMap(json.decode(source) as Map<String, dynamic>);
}
