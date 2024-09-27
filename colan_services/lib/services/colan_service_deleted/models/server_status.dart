import 'package:flutter/material.dart';

import '../../store_service/models/store_model.dart';
import 'cl_server.dart';

@immutable
class ActiveServer {
  const ActiveServer({
    this.server,
    this.workOffline = false,
    this.isOnline = false,
    this.storeCache,
  }) : canSync =
            storeCache != null && server != null && !workOffline && isOnline;
  final CLServer? server;
  final bool workOffline;
  final bool isOnline;
  final StoreCache? storeCache;
  final bool canSync;

  ActiveServer copyWith({
    ValueGetter<CLServer?>? server,
    bool? workOffline,
    bool? isOnline,
    ValueGetter<StoreCache?>? storeCache,
  }) {
    return ActiveServer(
      server: server != null ? server.call() : this.server,
      workOffline: workOffline ?? this.workOffline,
      isOnline: isOnline ?? this.isOnline,
      storeCache: storeCache != null ? storeCache.call() : this.storeCache,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ServerStatus(server: $server, workOffline: $workOffline, isOnline: $isOnline, storeCache: $storeCache)';
  }

  @override
  bool operator ==(covariant ActiveServer other) {
    if (identical(this, other)) return true;

    return other.server == server &&
        other.workOffline == workOffline &&
        other.isOnline == isOnline &&
        other.storeCache == storeCache;
  }

  @override
  int get hashCode {
    return server.hashCode ^
        workOffline.hashCode ^
        isOnline.hashCode ^
        storeCache.hashCode;
  }
}
