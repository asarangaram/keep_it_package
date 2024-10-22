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
abstract class ChangeTracker<T> {
  ChangeTracker({required this.current, required this.update}) {
    actionType = getActionType();
  }
  final T? current;
  final T? update;

  late final ActionType actionType;

  @override
  bool operator ==(covariant ChangeTracker<T> other) {
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

  bool get isContentSame;
  bool get hasServerUID;
  bool get isLocallyEditted;
  bool get isLocallyDeleted;
  bool get isLocalLatest;

  ActionType getActionType() {
    if (isContentSame) return ActionType.none;
    if (current == null) {
      return ActionType.download;
    }
    if (update == null) {
      if (hasServerUID) {
        return ActionType.deleteLocal;
      }
      return ActionType.upload;
    }
    if (!isLocallyEditted) {
      return ActionType.updateLocal;
    }
    // If the changes in local is new,
    /* if (isLocalLatest) 
   FIXME:  for now, always assume the local is forced */
    {
      if (isLocallyDeleted) {
        return ActionType.deleteOnServer;
      }

      return ActionType.updateOnServer;
    }
    /* return ActionType.markConflict; */
  }
}

@immutable
class MediaChangeTracker extends ChangeTracker<CLMedia> {
  MediaChangeTracker({required super.current, required super.update});

  @override
  bool get isContentSame =>
      current != null && update != null && current!.isContentSame(update!);

  @override
  bool get hasServerUID => current!.serverUID != null;

  @override
  bool get isLocallyEditted => current?.isEdited ?? false;

  @override
  bool get isLocallyDeleted => current!.isDeleted ?? false;

  @override
  bool get isLocalLatest => update!.updatedDate.isBefore(current!.updatedDate);
}

@immutable
class CollectionChangeTracker extends ChangeTracker<Collection> {
  CollectionChangeTracker({required super.current, required super.update});

  @override
  bool get isContentSame => false;
  //current != null && update != null && current!.isContentSame(update!);

  @override
  bool get hasServerUID => current!.serverUID != null;

  @override
  bool get isLocallyEditted => false; //current?.isEdited ?? false;

  @override
  bool get isLocallyDeleted => false; //current!.isDeleted ?? false;

  @override
  bool get isLocalLatest =>
      true; //update!.updatedDate.isBefore(current!.updatedDate);
}
