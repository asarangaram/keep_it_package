import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

enum ActionType {
  none,
  download, // GET
  upload, // POST
  deleteOnServer, // DELETE
  updateOnServer, // PUT
  deleteLocal, // delete permanently
  updateLocal, // Overwrite
  markConflict;
}

@immutable
class ChangeTracker {
  ChangeTracker({required this.current, required this.update}) {
    actionType = getActionType();
  }
  final CLEntity? current;
  final CLEntity? update;

  late final ActionType actionType;

  @override
  bool operator ==(covariant ChangeTracker other) {
    if (identical(this, other)) return true;

    return other.current == current && other.update == update;
  }

  @override
  int get hashCode => current.hashCode ^ update.hashCode;

  @override
  String toString() => 'TrackedMedia(current: $current, update: $update)';

  bool get isActionNone => actionType == ActionType.none;
  bool get isActionDownload => actionType == ActionType.download;
  bool get isActionUpload => actionType == ActionType.upload;
  bool get isActionDeleteOnServer => actionType == ActionType.deleteOnServer;
  bool get isActionUpdateOnServer => actionType == ActionType.updateOnServer;
  bool get isActionDeleteLocalCopy => actionType == ActionType.deleteLocal;
  bool get isActionUpdateLocalCopy => actionType == ActionType.updateLocal;
  bool get markConflict => actionType == ActionType.markConflict;

  ActionType getActionType() {
    if (current != null && update != null && current!.isContentSame(update!)) {
      return ActionType.none;
    }

    if (current == null) {
      return ActionType.download;
    }
    if (update == null) {
      if ((current!).isMarkedForUpload) {
        return ActionType.upload;
      }
      if ((current!).hasServerUID) {
        return ActionType.deleteLocal;
      }
      return ActionType.none;
    } else {
      if ((current!).isMarkedDeleted) {
        return ActionType.deleteOnServer;
      }
      if ((current!).isMarkedEditted) {
        return ActionType.updateOnServer;
      }
      return ActionType.updateLocal;
    }
  }
}
