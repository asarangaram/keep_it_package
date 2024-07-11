enum UniversalMediaSource {
  captured,
  move,
  filePick,
  incoming,
  unclassified;

  String get identifier => switch (this) {
        captured => 'Captured',
        move => 'Shared',
        filePick => 'Imported',
        unclassified => 'Unclassified',
        incoming => 'Incoming',
      };
  String get label => identifier;

  String get actionLabel => switch (this) {
        captured => 'Save',
        move => 'Move',
        filePick => 'Import',
        unclassified => 'Keep',
        incoming => 'Save',
      };

  bool get canDelete => switch (this) { move => false, _ => true };
}
