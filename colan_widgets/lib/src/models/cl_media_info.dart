// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


import 'cl_media_type.dart';

class CLMediaInfo {
  final String path;
  final CLMediaType type;
  CLMediaInfo({
    required this.path,
    required this.type,
  });

  CLMediaInfo copyWith({
    String? path,
    CLMediaType? type,
  }) {
    return CLMediaInfo(
      path: path ?? this.path,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'path': path,
      'type': type.name,
    };
  }

  factory CLMediaInfo.fromMap(Map<String, dynamic> map) {
    return CLMediaInfo(
      path: map['path'] as String,
      type: CLMediaType.values.asNameMap()[map['type']]!,
    );
  }

  String toJson() => json.encode(toMap());

  factory CLMediaInfo.fromJson(String source) =>
      CLMediaInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CLMediaInfo(path: $path, type: $type)';

  @override
  bool operator ==(covariant CLMediaInfo other) {
    if (identical(this, other)) return true;

    return other.path == path && other.type == type;
  }

  @override
  int get hashCode => path.hashCode ^ type.hashCode;
}

class CLMediaInfoGroup {
  final List<CLMediaInfo> list;
  CLMediaInfoGroup(this.list);

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;
}
