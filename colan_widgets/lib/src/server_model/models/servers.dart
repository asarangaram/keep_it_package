// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'cl_server.dart';

@immutable
class Servers {
  const Servers({
    required this.lanStatus,
    required this.servers,
    required this.myServerOnline,
    this.myServer,
  });

  factory Servers.unknown({CLServer? myServer}) {
    return Servers(
      lanStatus: false,
      servers: const {},
      myServerOnline: false,
      myServer: myServer,
    );
  }
  final bool lanStatus;
  final Set<CLServer> servers;
  final CLServer? myServer;
  final bool myServerOnline;

  Servers copyWith({
    bool? lanStatus,
    Set<CLServer>? servers,
    CLServer? myServer,
    bool? myServerOnline,
  }) {
    return Servers(
      lanStatus: lanStatus ?? this.lanStatus,
      servers: servers ?? this.servers,
      myServer: myServer ?? this.myServer,
      myServerOnline: myServerOnline ?? this.myServerOnline,
    );
  }

  @override
  bool operator ==(covariant Servers other) {
    if (identical(this, other)) return true;
    final setEquals = const DeepCollectionEquality().equals;

    return other.lanStatus == lanStatus &&
        setEquals(other.servers, servers) &&
        other.myServer == myServer &&
        other.myServerOnline == myServerOnline;
  }

  @override
  int get hashCode {
    return lanStatus.hashCode ^
        servers.hashCode ^
        myServer.hashCode ^
        myServerOnline.hashCode;
  }

  @override
  String toString() {
    return 'Servers(lanStatus: $lanStatus, servers: $servers, myServer: $myServer, myServerOnline: $myServerOnline)';
  }

  bool get isEmpty => servers.isEmpty;
  bool get isNotEmpty => servers.isNotEmpty;
}
