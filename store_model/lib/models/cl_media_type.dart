enum CLMediaType {
  text,
  image,
  video,
  url,
  audio,
  file;

  factory CLMediaType.fromMap(Map<String, dynamic> map) {
    return CLMediaType.values.asNameMap()[map['type'] as String]!;
  }

  bool get isFile => switch (this) { text => false, url => false, _ => true };

  bool get isSupported =>
      switch (this) { image => true, video => true, _ => false };
}
