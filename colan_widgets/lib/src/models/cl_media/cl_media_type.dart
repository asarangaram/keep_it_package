enum CLMediaType {
  text,
  image,
  video,
  url,
  audio,
  file;

  bool get isFile => switch (this) { text => false, url => false, _ => true };
}
