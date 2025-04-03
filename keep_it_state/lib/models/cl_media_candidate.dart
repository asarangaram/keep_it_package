import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

@immutable
class CLMediaCandidate {
  const CLMediaCandidate({
    required this.path,
    required this.type,
  });

  final String path;
  final CLMediaType type;

  Future<void> deleteFile() async {
    await File(path).deleteIfExists();
  }

  CLMediaCandidate copyWith({
    ValueGetter<String>? path,
    ValueGetter<CLMediaType>? type,
  }) {
    return CLMediaCandidate(
      path: path != null ? path() : this.path,
      type: type != null ? type() : this.type,
    );
  }

  @override
  String toString() => 'CLMediaBase(path: $path, type: $type)';

  @override
  bool operator ==(covariant CLMediaCandidate other) {
    if (identical(this, other)) return true;

    return other.path == path && other.type == type;
  }

  @override
  int get hashCode => path.hashCode ^ type.hashCode;
}

@immutable
class CLMediaFileGroup {
  const CLMediaFileGroup({
    required this.entries,
    required this.type,
    this.collection,
  });
  final List<CLMediaCandidate> entries;
  final CLMedia? collection;
  final UniversalMediaSource? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
}
