// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:content_store/src/models/cl_server.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Server {
  final CLServer? identity;
  final bool isOffline;
  final bool workingOffline;
  final bool isSyncing;
  final bool canSync;
  final bool isRegistered;
  const Server({
    this.identity,
    bool isOffline = true,
    this.workingOffline = true,
    this.isSyncing = false,
  })  : canSync = !workingOffline && !isOffline && identity != null,
        isRegistered = identity != null,
        isOffline = isOffline || identity == null;

  Server copyWith({
    ValueGetter<CLServer?>? identity,
    bool? isOffline,
    bool? workingOffline,
    bool? isSyncing,
  }) {
    return Server(
      identity: identity != null ? identity.call() : this.identity,
      isOffline: isOffline ?? this.isOffline,
      workingOffline: workingOffline ?? this.workingOffline,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'Server(identity: $identity, isOffline: $isOffline, workingOffline: $workingOffline, isSyncing: $isSyncing, canSync: $canSync, isRegistered: $isRegistered)';
  }

  @override
  bool operator ==(covariant Server other) {
    if (identical(this, other)) return true;

    return other.identity == identity &&
        other.isOffline == isOffline &&
        other.workingOffline == workingOffline &&
        other.isSyncing == isSyncing &&
        other.canSync == canSync &&
        other.isRegistered == isRegistered;
  }

  @override
  int get hashCode {
    return identity.hashCode ^
        isOffline.hashCode ^
        workingOffline.hashCode ^
        isSyncing.hashCode ^
        canSync.hashCode ^
        isRegistered.hashCode;
  }
}
