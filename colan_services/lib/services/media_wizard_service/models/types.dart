enum UniversalMediaTypes {
  captured,
  move,
  imported,
  staleMedia;

  String get identifier => switch (this) {
        captured => 'Captured',
        move => 'Shared',
        imported => 'Imported',
        staleMedia => 'Unclassified'
      };
  String get label => identifier;

  String get actionLabel => switch (this) {
        captured => 'Save',
        move => 'Move',
        imported => 'Import',
        staleMedia => 'Keep'
      };

  bool get canDelete => switch (this) { move => false, _ => true };
}
