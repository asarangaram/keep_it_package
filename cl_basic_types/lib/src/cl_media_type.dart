enum CLMediaType {
  collection,
  text,
  image,
  video,
  audio,
  file,
  uri,
  unknown;

  static CLMediaType fromMIMEType(String mimiType) {
    for (final type in CLMediaType.values) {
      if (mimiType.startsWith(type.name)) {
        return type;
      }
    }
    return CLMediaType.file;
  }
}
