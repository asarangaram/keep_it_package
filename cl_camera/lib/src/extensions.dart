extension EXTNextOnList<T> on List<T> {
  T next(T item) => this[(indexOf(item) + 1) % length];
}
