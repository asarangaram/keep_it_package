import 'package:meta/meta.dart';

import 'package:server/server.dart';
import 'package:store_revised/store_revised.dart';

@immutable
class ServerBasic {
  const ServerBasic(
      {this.previousIdentity,
      this.identity,
      bool isOffline = true,
      this.workingOffline = false})
      : canSync = !workingOffline && !isOffline && identity != null,
        isRegistered = identity != null,
        isOffline = isOffline || identity == null;
  final CLServer? identity;
  final bool isOffline;
  final bool workingOffline;
  final bool canSync;
  final bool isRegistered;

  final CLServer? previousIdentity;

  ServerBasic copyWith({
    ValueGetter<CLServer?>? previousIdentity,
    ValueGetter<CLServer?>? identity,
    bool? isOffline,
    bool? workingOffline,
  }) {
    return ServerBasic(
      identity: identity != null ? identity.call() : this.identity,
      isOffline: isOffline ?? this.isOffline,
      workingOffline: workingOffline ?? this.workingOffline,
      previousIdentity: previousIdentity != null
          ? previousIdentity.call()
          : this.previousIdentity,
    );
  }

  @override
  String toString() {
    return 'Server(identity: $identity, isOffline: $isOffline, workingOffline: $workingOffline, canSync: $canSync, isRegistered: $isRegistered, previousIdentity: $previousIdentity)';
  }

  @override
  bool operator ==(covariant ServerBasic other) {
    if (identical(this, other)) return true;

    return other.identity == identity &&
        other.isOffline == isOffline &&
        other.workingOffline == workingOffline &&
        other.canSync == canSync &&
        other.isRegistered == isRegistered &&
        other.previousIdentity == previousIdentity;
  }

  @override
  int get hashCode {
    return identity.hashCode ^
        isOffline.hashCode ^
        workingOffline.hashCode ^
        canSync.hashCode ^
        isRegistered.hashCode ^
        previousIdentity.hashCode;
  }
}
