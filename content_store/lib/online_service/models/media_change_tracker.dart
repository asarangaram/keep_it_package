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
class MediaChangeTracker {
  MediaChangeTracker({required this.current, required this.update}) {
    actionType = getActionType();
  }
  final CLMedia? current;
  final CLMedia? update;
  late final ActionType actionType;

  @override
  bool operator ==(covariant MediaChangeTracker other) {
    if (identical(this, other)) return true;

    return other.current == current && other.update == update;
  }

  @override
  int get hashCode => current.hashCode ^ update.hashCode;

  @override
  String toString() => 'TrackedMedia(current: $current, update: $update)';

  ActionType getActionType() {
    if (isContentSame) return ActionType.none;
    if (current == null) {
      return ActionType.download;
    }
    if (update == null) {
      if (current!.serverUID != null) {
        return ActionType.deleteLocal;
      }
      return ActionType.upload;
    }
    if (!current!.isEdited) {
      return ActionType.updateLocal;
    }
    // If the changes in local is new,
    /* if (update!.updatedDate.isBefore(current!.updatedDate)) 
   FIXME:  for now, always assume the local is forced */
    {
      if (current!.isDeleted ?? false) {
        return ActionType.deleteOnServer;
      }

      return ActionType.updateOnServer;
    }
    /* return ActionType.markConflict; */
  }

  bool get isContentSame =>
      current != null && update != null && current!.isContentSame(update!);

  bool get isActionNone => actionType == ActionType.none;
  bool get isActionDownload => actionType == ActionType.download;
  bool get isActionUpload => actionType == ActionType.upload;
  bool get isActionDeleteOnServer => actionType == ActionType.deleteOnServer;
  bool get isActionUpdateOnServer => actionType == ActionType.updateOnServer;
  bool get isActionDeleteLocalCopy => actionType == ActionType.deleteLocal;
  bool get isActionUpdateLocalCopy => actionType == ActionType.updateLocal;
  bool get markConflict => actionType == ActionType.markConflict;
}
