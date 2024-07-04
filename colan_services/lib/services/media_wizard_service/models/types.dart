enum UniversalMediaTypes {
  staleMedia;

  String get identifier => switch (this) { staleMedia => 'Unclassified Media' };
}
