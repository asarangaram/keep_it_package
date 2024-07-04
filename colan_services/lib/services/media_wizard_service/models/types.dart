enum UniversalMediaTypes {
  captured,
  shared,
  imported,
  staleMedia;

  String get identifier => switch (this) {
        captured => 'Captured',
        shared => 'Shared',
        imported => 'Imported',
        staleMedia => 'Unclassified'
      };
  String get label => identifier;

  String get actionLabel => switch (this) {
        captured => 'Save',
        shared => 'Save',
        imported => 'Import',
        staleMedia => 'Keep'
      };

  bool get canDelete => switch (this) { _ => true };
}
