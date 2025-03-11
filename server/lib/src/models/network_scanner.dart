import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../models/cl_server.dart';

@immutable
class NetworkScanner2 {
  const NetworkScanner2({
    required this.lanStatus,
    required this.servers,
  });

  factory NetworkScanner2.unknown() {
    return const NetworkScanner2(
      lanStatus: false,
      servers: null,
    );
  }
  final bool lanStatus;
  final Set<CLServer>? servers;

  NetworkScanner2 copyWith({
    bool? lanStatus,
    Set<CLServer>? servers,
  }) {
    return NetworkScanner2(
      lanStatus: lanStatus ?? this.lanStatus,
      servers: servers ?? this.servers,
    );
  }

  @override
  bool operator ==(covariant NetworkScanner2 other) {
    if (identical(this, other)) return true;
    final setEquals = const DeepCollectionEquality().equals;

    return other.lanStatus == lanStatus && setEquals(other.servers, servers);
  }

  @override
  int get hashCode => lanStatus.hashCode ^ servers.hashCode;

  @override
  String toString() =>
      'NetworkScanner2(lanStatus: $lanStatus, servers: $servers)';

  bool get isEmpty => servers?.isEmpty ?? true;
  bool get isNotEmpty => servers?.isNotEmpty ?? false;
}
