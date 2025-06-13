enum StoreTaskType {
  captured,
  move,
  filePick,
  incoming,
  deleted,
  unclassified;

  String get identifier => switch (this) {
        captured => 'Captured',
        move => 'Moving...',
        filePick => 'Imported',
        unclassified => 'Unclassified',
        incoming => 'Incoming',
        deleted => 'Deleted'
      };
  String get label => identifier;

  String get keepActionLabel => switch (this) {
        captured => 'Save',
        move => 'Move',
        filePick => 'Import',
        unclassified => 'Keep',
        incoming => 'Save',
        deleted => 'Restore'
      };
  String get deleteActionLabel => switch (this) {
        captured => 'Discard',
        move => 'Discard',
        filePick => 'Discard',
        unclassified => 'Discard',
        incoming => 'Discard',
        deleted => 'Delete'
      };

  bool get canDelete => switch (this) { move => false, _ => true };
}
