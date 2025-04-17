extension ExtExclude<T> on List<T> {
  Iterable<T> excludeByLabel(
    List<T> another,
    String Function(T obj) labelBuilder,
  ) {
    return where((e) {
      return !another.map(labelBuilder).contains(labelBuilder(e));
    });
  }

  Iterable<T> excludeLabel(
    String label,
    String Function(T obj) labelBuilder,
  ) {
    return where(
      (e) => labelBuilder(e) != label,
    );
  }

  T? getByLabel(
    String label,
    String Function(T obj) labelBuilder,
  ) {
    return where(
      (e) => labelBuilder(e) == label,
    ).firstOrNull;
  }
}
