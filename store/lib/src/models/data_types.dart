typedef ValueGetter<T> = T Function();

enum UpdateStrategy {
  skip,
  overwrite,
  mergeAppend,
}
